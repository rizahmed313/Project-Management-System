UPDATED README.md (FINAL VERSION)
# Salesforce Project Management (SFDX Deployable Package)

This repository contains a complete Salesforce Project Management solution built using:
- **Custom Objects:** Project__c, Milestone__c, ToDo__c  
- **Relationships:** Master-Detail between Project → Milestone, Milestone → ToDo  
- **Automation:** Roll-up summaries, formula-driven status fields  
- **Apex:** ProjectService (project creation + overview), ProjectServiceTest  
- **LWC:** `projectCreator` component for creating projects and listing all existing projects  
- **Validation:** Example rule on ToDo__c enforcing Due Date when marked complete  
- **Permission Set:** `Project_Creator_Permissions` for controlled access

---

# 🚀 Deployment Instructions

### **1. Authenticate to your Developer Org**
```bash
sfdx auth:web:login -a MyDevOrg

2. Deploy the SFDX Source Package
sfdx force:source:deploy -p project_metadata/force-app -u MyDevOrg

3. Assign the Permission Set
sfdx force:user:permset:assign -n Project_Creator_Permissions -u MyDevOrg

4. Run Apex Tests (Required for most assessments)
sfdx force:apex:test:run -u MyDevOrg --classnames ProjectServiceTest --resultformat human --wait 10

#🧩 Component Placement Instructions (User Guide)

After deployment, follow these steps to add the Project Creator LWC to a Lightning Page:

Add the LWC to a Lightning App Page (Recommended)

Go to Setup

Search for Lightning App Builder in Quick Find

Click New → App Page

Choose a layout (1 region recommended)

Name it: Project Management Console

Drag the component projectCreator onto the canvas

Click Save → Activate

Make it available in the App Launcher

Users can now access the page from the App Launcher.

Optional: Add the Component to the Home Page

Setup → Lightning App Builder → Home Page

Clone Default Home Page (recommended)

Drag projectCreator to the top region

Save + Activate

Optional: Add the Component to a Record Page

Navigate to any record (Project__c or any object)

Click Edit Page

Drag projectCreator into a section of the layout

Save + Activate

Note: The component does not require a recordId; it acts as a standalone “project creation + list” console.

🔐 Permission Set: Project_Management_Access

Included in this repo is a Permission Set granting:

Read/Write access to Project__c, Milestone__c, ToDo__c

Access to Apex class ProjectService

Access to Lightning Component projectCreator

Assign it to any user who needs to create and manage projects.


🧱 Project Architecture Overview
Data Model

Project__c

Name, Owner, Percent_Complete__c (formula), Status__c (formula)

Milestone__c

Master-Detail: Project__c

Rollups: Total_ToDos__c, Incomplete_ToDos__c

Percent_Complete__c formula, Status__c formula

ToDo__c

Master-Detail: Milestone__c

Checkbox: Is_Complete__c

Date: Due_Date__c

Validation rule requiring a due date when complete

Apex

createProjectWithChildren(payloadJson)

getAllProjects()

Wrapper-based getProjectOverview()

Comprehensive test class

LWC

Create new project with milestones + todos

Automatically load all projects

Display in datatable

Navigate to record via row action

📝 Notes & Caveats

Formula-based status fields ensure users cannot manually change project/milestone statuses.

Roll-up summaries require correct deployment order; this repo includes fields in correct object folders.

Deploy the entire force-app folder to avoid ordering issues.

Child relationship names used:

Project__c → Milestones__r

Milestone__c → ToDos__r

📬 Support

If you need help extending:

Inline editing of milestones or tasks

Adding charts or progress bars

Adding filters/search to the project table

Integration with Flows or Approval Processes

open an issue or contact the developer.