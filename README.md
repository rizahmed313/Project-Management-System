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
sf org login web --set-alias MyDevOrg
```

---

### **2. Deploy the SFDX Source Package**
```bash
sf project deploy start --source-path project_metadata/force-app --target-org MyDevOrg

```

---

### **3. Assign the Permission Set**
```bash
sf org assign permset --name Project_Creator_Permissions --target-org MyDevOrg
```

---

### **4. Run Apex Tests (Required for most assessments)**
```bash
sf apex run test --tests ProjectServiceTest --target-org MyDevOrg --wait 10 --result-format human
```

---

# 🧩 Component Placement Instructions (User Guide)

After deployment, follow these steps to add the **Project Creator LWC** to a Lightning Page.

---

## ✅ Add the LWC to a Lightning App Page (Recommended)

1. Go to **Setup**
2. Search for **Lightning App Builder** in Quick Find  
3. Click **New → App Page**
4. Choose a layout (1 region recommended)
5. Name it: **Project Management Console**
6. Drag the **projectCreator** component onto the canvas
7. Click **Save → Activate**
8. Expose it in the **App Launcher**

Users can now access the page directly from the App Launcher.

---

## ➕ Optional: Add Component to Home Page

1. Setup → Lightning App Builder → Home Page  
2. Clone **Default Home Page** (recommended)  
3. Drag the **projectCreator** component to the top  
4. Save + Activate  

---

## ➕ Optional: Add Component to a Record Page

1. Navigate to any **Project__c** or other record  
2. Click **Edit Page**  
3. Drag **projectCreator** onto a region  
4. Save + Activate  

💡 *Note: The component does **not** require a recordId. It behaves as a standalone “project creation + list” console.*

---

# 🔐 Permission Set: *Project_Creator_Permissions*

This permission set grants:

- Read/Write access to **Project__c**, **Milestone__c**, **ToDo__c**  
- Access to **Apex Class** `ProjectService`  
- Access to **Lightning Component** `projectCreator`  

Assign it to any user who needs permission to manage projects.

---

# 🧱 Project Architecture Overview

## **Data Model**

### **Project__c**
- Name  
- Owner  
- Percent_Complete__c *(formula)*  
- Status__c *(formula)*  

### **Milestone__c**
- Master-Detail: Project__c  
- Rollups: Total_ToDos__c, Incomplete_ToDos__c  
- Percent_Complete__c *(formula)*  
- Status__c *(formula)*  

### **ToDo__c**
- Master-Detail: Milestone__c  
- Checkbox: Is_Complete__c  
- Date: Due_Date__c  
- Validation rule enforcing due date when complete  

---

## **Apex**
- `createProjectWithChildren(payloadJson)`  
- `getAllProjects()`  
- `getProjectOverview()` (wrapper-based)  
- Full test class: `ProjectServiceTest`

---

## **LWC**
- Create a new project with milestones + tasks  
- Automatically load all projects into a datatable  
- Provide row action to navigate to project record page  
- Fully dynamic milestone/task management UX  

---

# 📝 Notes & Caveats

- Formula fields ensure users **cannot manually change** Project or Milestone statuses.  
- Roll-up summary fields require correct object/field order; this repo handles that.  
- Deploy the entire `force-app` folder if you experience ordering issues.  
- Child relationship names used:  
  - Project__c → `Milestones__r`  
  - Milestone__c → `ToDos__r`  

---

# 📬 Support

If you need enhancements such as:

- Inline editing of milestones or tasks  
- Adding charts or progress indicators  
- Advanced filtering/search  
- Integration with Flows or Approvals  

Feel free to extend the code or request improvements.
