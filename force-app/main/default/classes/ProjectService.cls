public with sharing class ProjectService {

    
    public class ToDoWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean isComplete;
    }

    public class MilestoneWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public List<ToDoWrapper> todos;
    }

    public class ProjectWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Id ownerId;
        @AuraEnabled public List<MilestoneWrapper> milestones;
    }

    public class ProjectWithChildren {
    @AuraEnabled public Project__c project;
    @AuraEnabled public List<MilestoneWithToDos> milestones;
    }

    public class MilestoneWithToDos {
        @AuraEnabled public Milestone__c milestone;
        @AuraEnabled public List<ToDo__c> todos;
    }

    // ------------------------------------------
    // CREATE PROJECT WITH CHILD RECORDS
    // ------------------------------------------
    @AuraEnabled
    public static Id createProjectWithChildren(String  payloadJson) {
        
        ProjectWrapper payload;

        try {
            payload = (ProjectWrapper) JSON.deserialize(payloadJson, ProjectWrapper.class);
        } catch (Exception e) {
            throw new AuraHandledException('Error parsing payload JSON: ' + e.getMessage());
        }
       System.debug('🔥 RECEIVED PAYLOAD: ' + JSON.serialize(payload));
        if (payload == null) throw new AuraHandledException('Payload missing');
        if (String.isBlank(payload.Name)) throw new AuraHandledException('Project Name is required');

        Project__c p = new Project__c(
            Name = payload.Name,
            OwnerId = payload.OwnerId
        );
        insert p;

        List<Milestone__c> milestonesToInsert = new List<Milestone__c>();
        Map<Integer, List<ToDo__c>> idxToTodos = new Map<Integer, List<ToDo__c>>();
        Integer idx = 0;

        if (payload.milestones != null) {
            for (MilestoneWrapper mw : payload.milestones) {

                Milestone__c m = new Milestone__c(
                    Name = mw.Name,
                    Project__c = p.Id
                );
                milestonesToInsert.add(m);

                List<ToDo__c> todoList = new List<ToDo__c>();

                if (mw.todos != null) {
                    for (ToDoWrapper tw : mw.todos) {
                        todoList.add(new ToDo__c(
                            Name = tw.Name,
                            Is_Complete__c = tw.isComplete
                        ));
                    }
                }

                idxToTodos.put(idx, todoList);
                idx++;
            }
        }

        insert milestonesToInsert;

        idx = 0;
        for (Milestone__c insertedM : milestonesToInsert) {
            List<ToDo__c> tlist = idxToTodos.get(idx);
            if (tlist != null) {
                for (ToDo__c t : tlist) {
                    t.Milestone__c = insertedM.Id;
                }
                insert tlist;
            }
            idx++;
        }

        return p.Id;
    }
    // ------------------------------------------
    @AuraEnabled()
    public static List<Project__c> getAllProjects() {
        List<Project__c> projects = new List<Project__c>();
        projects = [SELECT Id, Name, Owner.Name,Status__c,Percent_Complete__c, CreatedDate FROM Project__c ORDER BY CreatedDate DESC];
        system.debug(projects);
        return projects;
    }
}