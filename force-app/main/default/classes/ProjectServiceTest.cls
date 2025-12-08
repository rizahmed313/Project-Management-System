@IsTest
private class ProjectServiceTest {
    @IsTest static void testCreateProjectWithChildren() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        ProjectService.ProjectWrapper pw = new ProjectService.ProjectWrapper();
        pw.Name = 'Test Project ' + String.valueOf(Datetime.now().getTime());
        pw.OwnerId = u.Id;
        pw.milestones = new List<ProjectService.MilestoneWrapper>();

        ProjectService.MilestoneWrapper m1 = new ProjectService.MilestoneWrapper();
        m1.Name = 'Milestone 1';
        m1.todos = new List<ProjectService.ToDoWrapper>();
        ProjectService.ToDoWrapper t11 = new ProjectService.ToDoWrapper(); t11.Name='Task 1.1'; t11.Is_Complete = false;
        ProjectService.ToDoWrapper t12 = new ProjectService.ToDoWrapper(); t12.Name='Task 1.2'; t12.Is_Complete = true;
        m1.todos.add(t11); m1.todos.add(t12);

        ProjectService.MilestoneWrapper m2 = new ProjectService.MilestoneWrapper();
        m2.Name = 'Milestone 2';
        m2.todos = new List<ProjectService.ToDoWrapper>();
        ProjectService.ToDoWrapper t21 = new ProjectService.ToDoWrapper(); t21.Name='Task 2.1'; t21.Is_Complete = false;
        m2.todos.add(t21);

        pw.milestones.add(m1); pw.milestones.add(m2);

        Test.startTest();
        Id projId = ProjectService.createProjectWithChildren(pw);
        Test.stopTest();

        System.assertNotEquals(null, projId, 'Project created');

        Project__c proj = [SELECT Id, Name, Percent_Complete__c FROM Project__c WHERE Id=:projId];
        System.assertEquals(pw.Name, proj.Name);

        List<Milestone__c> mlist = [SELECT Id, Name FROM Milestone__c WHERE Project__c=:projId];
        System.assertEquals(2, mlist.size(), '2 milestones should exist');

        List<ToDo__c> tlist = [SELECT Id, Name, Is_Complete__c, Milestone__c FROM ToDo__c WHERE Milestone__c IN :mlist];
        System.assertEquals(3, tlist.size(), '3 todos should exist');

        Integer todoCount = [SELECT count() FROM ToDo__c WHERE Milestone__c IN :mlist];
        System.assertEquals(3, todoCount);

        System.assert(proj.Percent_Complete__c >= 0 && proj.Percent_Complete__c <= 100, 'Percent in bounds');
    }

    @IsTest static void testBadPayload() {
        Test.startTest();
        try {
            ProjectService.createProjectWithChildren(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException);
        }
        Test.stopTest();
    }
}