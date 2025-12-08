# Salesforce Project Management (SFDX deployable)

This repository contains a complete SFDX-style source package for a small Project Management solution:
- Custom objects: Project__c, Milestone__c, ToDo__c
- Fields: master-detail relationships, roll-up summary fields, formula fields, checkbox, date
- Apex: ProjectService (Apex controller) and ProjectServiceTest (unit tests)
- LWC: projectCreator (form to create Project + Milestones + ToDos and preview)
- Validation rule example on ToDo__c

## How to deploy

1. Authenticate to your target org:
   ```
   sfdx auth:web:login -a MyDevOrg
   ```

2. Deploy source:
   ```
   sfdx force:source:deploy -p project_metadata/force-app -u MyDevOrg
   ```

3. Run tests:
   ```
   sfdx force:apex:test:run -u MyDevOrg --classnames ProjectServiceTest --resultformat human --wait 10
   ```

4. Add the `projectCreator` LWC to a Lightning App Page / Home Page / Record Page using Lightning App Builder.

## Notes & caveats

- The package is prepared in **source format** and ready to deploy with `sfdx force:source:deploy`.
- Roll-up summary fields depend on master-detail relationships; the files are included in the correct order in the `objects/` folder.
- Formula fields are read-only, which enforces the requirement that **Status** cannot be edited manually.
- If deployment fails due to ordering issues, deploy the whole `force-app` directory (recommended) instead of individual files.
- Child relationship API names used in Apex and LWC:
  - Milestones child list on Project__c -> `Milestones__r`
  - ToDos child list on Milestone__c -> `ToDos__r`


