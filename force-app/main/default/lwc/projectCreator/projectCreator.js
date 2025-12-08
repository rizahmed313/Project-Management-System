import { LightningElement, track } from 'lwc';
import createProjectWithChildren from '@salesforce/apex/ProjectService.createProjectWithChildren';
import getAllProjects from '@salesforce/apex/ProjectService.getAllProjects';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';

export default class ProjectCreator extends NavigationMixin(LightningElement) {
    @track projectName = '';
    @track ownerId = USER_ID;
    @track milestones = [];
    @track allProjects = [];

    projectColumns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: '% Complete', fieldName: 'Percent_Complete__c', type: 'percent' },
    { label: 'Owner', fieldName: 'OwnerName', type: 'text' },
    {
        type: 'button',
        typeAttributes: {
            label: 'View',
            name: 'viewDetails',
            variant: 'brand'
        }
    }
    ];

    connectedCallback() {
        this.addMilestone();
         this.loadProjects();
    }

    indexToLabel(i) {
        return i + 1;
    }
    
    loadProjects() {
    getAllProjects()
        .then(list => {
            this.allProjects = list.map(row => ({
                ...row,
                OwnerName: row.Owner?.Name  
            }));
        })
        .catch(error => {
            console.error('Error fetching projects:', error);
        });
    }

    updateToDoLabels(mIndex) {
        const todos = this.milestones[mIndex].todos;
        for (let t = 0; t < todos.length; t++) {
            todos[t].label = 'To-Do ' + (t + 1);
        }
    }

    // Helper: update labels for all milestones
    updateAllLabels() {
        for (let m = 0; m < this.milestones.length; m++) {
            this.updateToDoLabels(m);
        }
    }

    // Add milestone creates an initial todo and sets labels
    addMilestone() {
        this.milestones = [
            ...this.milestones,
            {
                key: Date.now() + Math.random(),
                name: '',label: 'Milestone ' + (this.milestones.length + 1),
                todos: [
                    { key: Date.now() + '_td_' + Math.random(), name: '', isComplete: false, label: 'To-Do 1' }
                ]
            }
        ];
        this.updateAllLabels();
        this.milestones = [...this.milestones];
    }

    updateMilestoneLabels() {
    for (let i = 0; i < this.milestones.length; i++) {
        this.milestones[i].label = 'Milestone ' + (i + 1);
    }
}


    removeMilestone(event) {
        const idx = Number(event.target.dataset.index);
        this.milestones.splice(idx, 1);
        // Recompute labels for remaining milestones' todos
        this.updateAllLabels();
        this.updateMilestoneLabels();
        this.milestones = [...this.milestones];
    }

    handleProjectNameChange(event) {
        this.projectName = event.target.value;
    }

    handleOwnerChange(event) {
        this.ownerId = event.target.value;
    }

    handleMilestoneNameChange(event) {
        const idx = Number(event.target.dataset.index);
        this.milestones[idx].name = event.target.value;
        this.milestones = [...this.milestones];
    }

    addToDo(event) {
        const idx = Number(event.target.dataset.index);
        this.milestones[idx].todos.push({
            key: Date.now() + '_td_' + Math.random(),
            name: '',
            isComplete: false,
            label: '' // will be filled next
        });
        // update labels for that milestone
        this.updateToDoLabels(idx);
        this.milestones = [...this.milestones];
    }

    removeToDo(event) {
        const midx = Number(event.target.dataset.milestoneindex);
        const tidx = Number(event.target.dataset.todoindex);
        this.milestones[midx].todos.splice(tidx, 1);
        // re-label remaining todos under that milestone
        this.updateToDoLabels(midx);
        this.milestones = [...this.milestones];
    }

    handleToDoNameChange(event) {
        const midx = Number(event.target.dataset.milestoneindex);
        const tidx = Number(event.target.dataset.todoindex);
        this.milestones[midx].todos[tidx].name = event.target.value;
        this.milestones = [...this.milestones];
    }

    handleToDoCompleteChange(event) {
        const midx = Number(event.target.dataset.milestoneindex);
        const tidx = Number(event.target.dataset.todoindex);
        this.milestones[midx].todos[tidx].isComplete = event.target.checked;
        this.milestones = [...this.milestones];
    }

    handleReset() {
        this.projectName = '';
        this.ownerId = USER_ID;
        this.milestones = [];
        this.addMilestone();
    }

    handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === 'viewDetails') {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Project__c',
                actionName: 'view'
            }
        });
    }
    }


    handleCreate() {
    if (!this.projectName.trim()) {
        console.log('Project Name required');
        return;
    }

    const payload = {
        name: this.projectName,
        ownerId: this.ownerId,
        milestones: this.milestones.map(m => ({
            Name: m.name,
            todos: (m.todos || []).map(t => ({
                name: t.name,
                isComplete: !!t.isComplete
            }))
        }))
    };

    createProjectWithChildren({ payloadJson: JSON.stringify(payload) })
        .then(() => {
            // After creation, fetch all projects
            this.loadProjects();
        })
        .then(list => {
            this.allProjects = list;
            console.log('Projects fetched:', list);
        })
        .catch(err => {
            console.error(err);
            alert(err.body?.message || err.message);
        });
    }

}