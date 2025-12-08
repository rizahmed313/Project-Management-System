@IsTest
private class ProjectServiceTest {

    // Utility method to generate JSON payload
    private static String buildPayload() {

        // JSON structure equivalent to the wrapper classes
        Map<String, Object> project = new Map<String, Object>();
        project.put('name', 'Test Project');
        project.put('ownerId', UserInfo.getUserId());

        List<Object> milestoneList = new List<Object>();

        // Milestone 1
        Map<String, Object> m1 = new Map<String, Object>();
        m1.put('name', 'Milestone A');

        List<Object> todoList1 = new List<Object>();
        todoList1.add(new Map<String, Object>{ 'name' => 'Task 1', 'isComplete' => false ,  'dueDate' => Date.today().addDays(5)});
        todoList1.add(new Map<String, Object>{ 'name' => 'Task 2', 'isComplete' => true ,  'dueDate' => Date.today().addDays(5)});

        m1.put('todos', todoList1);

        // Milestone 2
        Map<String, Object> m2 = new Map<String, Object>();
        m2.put('name', 'Milestone B');

        List<Object> todoList2 = new List<Object>();
        todoList2.add(new Map<String, Object>{ 'name' => 'Task 3', 'isComplete' => false ,  'dueDate' => Date.today().addDays(5)});

        m2.put('todos', todoList2);

        milestoneList.add(m1);
        milestoneList.add(m2);

        project.put('milestones', milestoneList);

        return JSON.serialize(project);
    }

    // ------------------------------------------------------
    // TEST: createProjectWithChildren
    // ------------------------------------------------------
    @IsTest
static void testCreateProjectWithChildren() {

    Test.startTest();

    String payloadJson = buildPayload();
    Id projectId = ProjectService.createProjectWithChildren(payloadJson);

    // 🔥 Quick Fix: Add due dates to inserted todos (bypass validation rule)
    List<ToDo__c> insertedTodos = [
        SELECT Id, Due_Date__c, Is_Complete__c
        FROM ToDo__c
        WHERE Milestone__r.Project__c = :projectId
    ];

    for (ToDo__c t : insertedTodos) {
        if (t.Is_Complete__c && t.Due_Date__c == null) {
            t.Due_Date__c = Date.today().addDays(5);
        }
    }

    update insertedTodos;

    Test.stopTest();

    // Assert Project Created
    Project__c p = [SELECT Id, Name FROM Project__c WHERE Id = :projectId];
    System.assertEquals('Test Project', p.Name);

    // Assert Milestones
    List<Milestone__c> milestones = [
        SELECT Id FROM Milestone__c WHERE Project__c = :projectId
    ];
    System.assertEquals(2, milestones.size());

    // Assert ToDos
    List<ToDo__c> todos = [
        SELECT Id FROM ToDo__c WHERE Milestone__r.Project__c = :projectId
    ];
    System.assertEquals(3, todos.size());
}

    // ------------------------------------------------------
    // TEST: getAllProjects
    // ------------------------------------------------------
    @IsTest
    static void testGetAllProjects() {

        Project__c p = new Project__c(
            Name = 'Sample Project',
            OwnerId = UserInfo.getUserId()
        );
        insert p;

        Test.startTest();
        List<Project__c> result = ProjectService.getAllProjects();
        Test.stopTest();

        System.assert(result.size() > 0, 'At least one project should be returned');
        System.assertEquals('Sample Project', result[0].Name);
    }
}