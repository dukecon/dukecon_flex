package ormtest
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import mx.collections.ArrayCollection;
    import mx.collections.IList;

    import nz.co.codec.flexorm.EntityManager;
    import nz.co.codec.flexorm.criteria.Criteria;
    import nz.co.codec.flexorm.criteria.Sort;
    import nz.co.codec.flexorm.util.ArrayStore;

    import ormtest.model.A;
    import ormtest.model.AppSetting;
    import ormtest.model.Author;
    import ormtest.model.B;
    import ormtest.model.Book;
    import ormtest.model.C;
    import ormtest.model.Contact;
    import ormtest.model.D;
    import ormtest.model.E;
    import ormtest.model.F;
    import ormtest.model.G;
    import ormtest.model.Gallery;
    import ormtest.model.Lesson;
    import ormtest.model.Order;
    import ormtest.model.Organisation;
    import ormtest.model.Part;
    import ormtest.model.Resource;
    import ormtest.model.Role;
    import ormtest.model.Schedule;
    import ormtest.model.Student;
    import ormtest.model.Vehicle;
    import ormtest.model.Year;
    import ormtest.model2.Person;
    import ormtest.model3.User3;
    import ormtest.model4.Role4;
    import ormtest.model4.RoleGroup4;
    import ormtest.model4.User4;
    import ormtest.model4.UserLight4;
    import ormtest.model4.UserLightView4;
    import ormtest.model5.ResultVO;
    import ormtest.model6.Employee6;
    import ormtest.model6.EmployeeDetail6;
    import ormtest.model7.Role7;
    import ormtest.model7.RoleGroup7;
    import ormtest.model7.User7;
    import ormtest.model8.RoleGroup8;
    import ormtest.model8.User8;
    import ormtest.model8.User8FromView;
    import ormtest.model9.Book9;
    import ormtest.model10.RoleGroup10;
    import ormtest.model10.User10;
    import ormtest.model11.Part11;
    import ormtest.model11.PartStatus11;
    import ormtest.model12.Book12;
    import ormtest.model12.KeyOwner12;
    import ormtest.model12.Room12;

    public class EntityManagerTest extends TestCase
    {
        private static var em:EntityManager = EntityManager.instance;

        public static function suite():TestSuite
        {
            em.debugLevel = 1;
            //            em.prefs = {
            //            	auditable: false,
            //            	markForDeletion: false
            //            };
            var ts:TestSuite = new TestSuite();

            ts.addTest(new EntityManagerTest("testSaveSimpleObject"));
            ts.addTest(new EntityManagerTest("testFindAll"));
            ts.addTest(new EntityManagerTest("testSaveManyToOneAssociation"));
            ts.addTest(new EntityManagerTest("testSaveOneToManyAssociations"));
            ts.addTest(new EntityManagerTest("testSaveManyToManyAssociation"));
            ts.addTest(new EntityManagerTest("testDelete"));
            ts.addTest(new EntityManagerTest("testCascadeSaveUpdate"));
            ts.addTest(new EntityManagerTest("testInheritance1"));
            ts.addTest(new EntityManagerTest("testInheritance2"));
            ts.addTest(new EntityManagerTest("testTransaction"));
            ts.addTest(new EntityManagerTest("testAlternateAPI"));
            ts.addTest(new EntityManagerTest("testCompositeKey"));
            ts.addTest(new EntityManagerTest("testCompositeKeyOneToMany"));
            ts.addTest(new EntityManagerTest("testOneToManyIndexedCollection"));
            ts.addTest(new EntityManagerTest("testManyToManyIndexedCollection"));
            ts.addTest(new EntityManagerTest("testDeepCompositeKeyNesting"));
            ts.addTest(new EntityManagerTest("testSaveUntypedObject"));
            ts.addTest(new EntityManagerTest("testSaveManyToOneUntypedObject"));
            ts.addTest(new EntityManagerTest("testSaveOneToManyUntypedObject"));
            ts.addTest(new EntityManagerTest("testRecursiveJoin"));
            ts.addTest(new EntityManagerTest("testLazyLoading"));
            ts.addTest(new EntityManagerTest("testCriteriaAPI"));
            ts.addTest(new EntityManagerTest("testCriteriaAPI2"));
            ts.addTest(new EntityManagerTest("testCriteriaAPI3"));
            ts.addTest(new EntityManagerTest("testCriteriaAPI4a"));
            ts.addTest(new EntityManagerTest("testCriteriaAPI4b"));
            ts.addTest(new EntityManagerTest("testAssignedIdStrategy"));
            ts.addTest(new EntityManagerTest("testAssignedIdStrategyUsingString"));

            ts.addTest(new EntityManagerTest("simpleManyToManyRelationshipTest"));
            ts.addTest(new EntityManagerTest("testMappedSuperclass"));
            ts.addTest(new EntityManagerTest("testManyToManyFindAll"));
            ts.addTest(new EntityManagerTest("testUpperCaseDatabase"));
            ts.addTest(new EntityManagerTest("testManyToManyAssocTable"));
            ts.addTest(new EntityManagerTest("testViewPresent"));
            ts.addTest(new EntityManagerTest("testViewAsManyToManyAssocTable"));
            ts.addTest(new EntityManagerTest("testFillEnum2"));
            ts.addTest(new EntityManagerTest("testSaveOneToOne"));

            // ts.addTest(new EntityManagerTest("testNullable"));
            return ts;
        }

        private const IMPORT_KEY:int = 1; // NOTE: usage of ID=0 is not supported by FlexORM

        public function EntityManagerTest(methodName:String = null)
        {
            super(methodName);
        }

        public function testSaveSimpleObject():void
        {
            trace("\nTest Save Simple Object");
            trace("=======================");
            var organisation:Organisation = new Organisation();
            organisation.name = "Codec Software Limited";
            em.save(organisation);

            var loadedOrganisation:Organisation = em.load(Organisation, organisation.id) as Organisation;
            assertEquals(loadedOrganisation.name, "Codec Software Limited");
        }

        public function testFindAll():void
        {
            trace("\nTest Find All");
            trace("=============");
            var adobe:Organisation = new Organisation();
            adobe.name = "Adobe";
            em.save(adobe);
            var fogCreek:Organisation = new Organisation();
            fogCreek.name = "Fog Creek";
            em.save(fogCreek);

            var organisations:ArrayCollection = em.findAll(Organisation);
            assertEquals(organisations.length, 3);
        }

        public function testSaveManyToOneAssociation():void
        {
            trace("\nTest Save Many To One Association");
            trace("=================================");
            var organisation:Organisation = new Organisation();
            organisation.name = "Apple";
            // since Organisation has cascade="none" on Contact
            em.save(organisation);

            var contact:Contact = new Contact();
            contact.name = "Steve";
            contact.organisation = organisation;
            em.save(contact);

            var loadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertNotNull(loadedContact);
            assertNotNull(loadedContact.organisation);
            assertEquals(loadedContact.organisation.name, "Apple");
        }

        public function testSaveOneToManyAssociations():void
        {
            trace("\nTest Save One To Many Associations");
            trace("==================================");
            var orders:ArrayCollection = new ArrayCollection();

            var order1:Order = new Order();
            order1.item = "Flex Builder 3";

            var order2:Order = new Order();
            order2.item = "CS3 Fireworks";

            orders.addItem(order1);
            orders.addItem(order2);

            var contact:Contact = new Contact();
            contact.name = "Greg";
            contact.orders = orders;
            em.save(contact);

            var loadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(loadedContact.orders.length, 2);
        }

        public function testSaveManyToManyAssociation():void
        {
            trace("\nTest Save Many To Many Associations");
            trace("===================================");
            var roles:ArrayCollection = new ArrayCollection();

            var role1:Role = new Role();
            role1.name = "Project Manager";

            var role2:Role = new Role();
            role2.name = "Business Analyst";

            roles.addItem(role1);
            roles.addItem(role2);

            var contact:Contact = new Contact();
            contact.name = "Shannon";
            contact.roles = roles;
            em.save(contact);

            var loadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(loadedContact.roles.length, 2);
        }

        public function testDelete():void
        {
            trace("\nTest Delete");
            trace("===========");
            var organisation:Organisation = new Organisation();
            organisation.name = "Datacom";
            em.save(organisation);

            em.remove(organisation);
            var loadedOrganisation:Organisation = em.load(Organisation, organisation.id) as Organisation;
            assertNull(loadedOrganisation);
        }

        public function testCascadeSaveUpdate():void
        {
            trace("\nTest Cascade Save Update");
            trace("========================");
            var orders:ArrayCollection = new ArrayCollection();

            var order1:Order = new Order();
            order1.item = "Bach";

            var order2:Order = new Order();
            order2.item = "BMW";

            orders.addItem(order1);
            orders.addItem(order2);

            var contact:Contact = new Contact();
            contact.name = "Jen";
            contact.orders = orders; // cascade="save-update"
            em.save(contact);

            var orderId:int = order2.id;

            // verify that cascade save-update works
            assertTrue(orderId > 0);

            // since the orders association is cascade="save-update" only
            //			for each(var o:Order in contact.orders)
            //			{
            //				em.remove(o);
            //			}
            em.remove(contact);

            // verify that cascade delete is not in effect

            // !!! Yes, but foreign key constraint violation is
            // so FK constraint has been switched off using constrain="false"
            var loadedOrder:Order = em.load(Order, orderId) as Order;
            assertEquals(loadedOrder.item, "BMW");
        }

        public function testInheritance1():void
        {
            trace("\nTest Inheritance 1");
            trace("==================");
            var person:Person = new Person();
            person.emailAddr = "person@acme.com";
            em.save(person);

            var loadedPerson:Person = em.load(Person, person.id) as Person;
            assertEquals(loadedPerson.emailAddr, "person@acme.com");
        }

        public function testInheritance2():void
        {
            trace("\nTest Inheritance 2");
            trace("==================");
            var contact:Contact = new Contact();
            contact.name = "Bill";
            contact.emailAddr = "bill@ms.com";
            em.save(contact);

            var loadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(loadedContact.emailAddr, "bill@ms.com");

            var loadedPerson:Person = em.load(Person, contact.id) as Person;
            assertEquals(loadedPerson.emailAddr, "bill@ms.com");
        }

        public function testTransaction():void
        {
            trace("\nTest Transactions");
            trace("=================");

            em.startTransaction();

            var organisation:Organisation = new Organisation();
            organisation.name = "Google";
            em.save(organisation);

            var contact:Contact = new Contact();
            contact.name = "Sergey";
            contact.organisation = organisation;
            em.save(contact);

            // The remove action is expected to fail with a
            // foreign key constraint violation (which causes a rollback)
            // it also causes the transaction to end

            em.remove(organisation);
            assertFalse(em.sqlConnection.inTransaction);

            em.endTransaction(); // actually does nothing here, as the transaction is already gone

            // due to the rollback the above data is gone
            var loadedOrganisation:Organisation = em.load(Organisation, organisation.id) as Organisation;
            assertNull(loadedOrganisation);
        }

        public function testAlternateAPI():void
        {
            trace("\nTest Alternate API");
            trace("==================");
            em.makePersistent(Organisation);

            var organisation:Organisation = new Organisation();
            organisation.name = "Datacom";
            organisation.save();

            var loadedOrganisation:Organisation = em.load(Organisation, organisation.id) as Organisation;
            assertEquals(loadedOrganisation.name, "Datacom");
        }

        public function testCompositeKey():void
        {
            trace("\nTest Composite Key");
            trace("==================");
            var student:Student = new Student();
            student.name = "Mark";
            em.save(student);

            var lesson:Lesson = new Lesson();
            lesson.name = "Piano";
            em.save(lesson);

            var schedule:Schedule = new Schedule();
            schedule.student = student;
            schedule.lesson = lesson;
            var today:Date = new Date();
            schedule.lessonDate = today;
            em.save(schedule);

            var loadedSchedule:Schedule = em.loadItemByCompositeKey(Schedule, [student, lesson]) as Schedule;

            // date.time comparison shows difference - could ms difference
            // when loading to/from database
            //			assertEquals(loadedSchedule.date, today);

            assertEquals(loadedSchedule.lessonDate.fullYear, today.fullYear);
            assertEquals(loadedSchedule.lessonDate.month, today.month);
            assertEquals(loadedSchedule.lessonDate.date, today.date);
        }

        public function testCompositeKeyOneToMany():void
        {
            trace("\nTest Composite Key with One-to-many");
            trace("===================================");
            var student:Student = new Student();
            student.name = "Shannon";
            em.save(student);

            var lesson:Lesson = new Lesson();
            lesson.name = "Viola";
            em.save(lesson);

            var schedule:Schedule = new Schedule();
            schedule.student = student;
            schedule.lesson = lesson;
            var today:Date = new Date();
            schedule.lessonDate = today;

            var stand:Resource = new Resource();
            stand.name = "Stand";

            var score:Resource = new Resource();
            score.name = "Mozart";

            var resources:ArrayCollection = new ArrayCollection();
            resources.addItem(stand);
            resources.addItem(score);
            schedule.resources = resources;

            em.save(schedule);

            var loadedSchedule:Schedule = em.loadItemByCompositeKey(Schedule, [student, lesson]) as Schedule;

            assertEquals(loadedSchedule.resources.length, 2);
        }

        public function testOneToManyIndexedCollection():void
        {
            trace("\nTest One To Many Indexed Collection");
            trace("===================================");
            var orders:ArrayCollection = new ArrayCollection();

            var order1:Order = new Order();
            order1.item = "Macbook";

            var order2:Order = new Order();
            order2.item = "iPhone";

            orders.addItem(order1);
            orders.addItem(order2);

            var contact:Contact = new Contact();
            contact.name = "Mark";
            contact.orders = orders;
            em.save(contact);

            var loadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(loadedContact.orders[1].item, "iPhone");

            var orderList:IList = loadedContact.orders;
            orderList.addItemAt(orderList.removeItemAt(1), 0);
            em.save(loadedContact);

            var reloadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(reloadedContact.orders[1].item, "Macbook");
        }

        public function testManyToManyIndexedCollection():void
        {
            trace("\nTest Many To Many Indexed Collection");
            trace("====================================");
            var roles:ArrayCollection = new ArrayCollection();

            var role1:Role = new Role();
            role1.name = "Carpenter";

            var role2:Role = new Role();
            role2.name = "Sparky";

            roles.addItem(role1);
            roles.addItem(role2);

            var contact:Contact = new Contact();
            contact.name = "John";
            contact.roles = roles;
            em.save(contact);

            var loadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(loadedContact.roles[1].name, "Sparky");

            var roleList:IList = loadedContact.roles;
            roleList.addItemAt(roleList.removeItemAt(1), 0);
            em.save(loadedContact);

            var reloadedContact:Contact = em.load(Contact, contact.id) as Contact;
            assertEquals(reloadedContact.roles[1].name, "Carpenter");
        }

        public function testDeepCompositeKeyNesting():void
        {
            trace("\nTest Deep Composite Key Nesting");
            trace("===============================");
            var a:A = new A();
            a.name = "A";
            em.save(a);

            var b:B = new B();
            b.name = "B";
            em.save(b);

            var c:C = new C();
            c.name = "C";
            em.save(c);

            var d:D = new D();
            d.name = "D";
            em.save(d);

            var e:E = new E();
            e.a = a;
            e.b = b;
            e.name = "E";
            em.save(e);

            var f:F = new F();
            f.c = c;
            f.d = d;
            f.name = "F";
            em.save(f);

            var g:G = new G();
            g.e = e;
            g.f = f;
            g.name = "G";
            em.save(g);

            var loadedG:G = em.loadItemByCompositeKey(G, [e, f]) as G;
            assertEquals(loadedG.e.a.name, "A");
        }

        public function testSaveUntypedObject():void
        {
            trace("\nTest Save Untyped Object");
            trace("========================");
            var obj:Object = new Object();
            obj.name = "Test Object";

            var handle:int = em.save(obj, {name: "test"});
            var loadedObject:Object = em.loadDynamicObject("test", handle);
            assertEquals(loadedObject.name, "Test Object");
        }

        public function testSaveManyToOneUntypedObject():void
        {
            trace("\nTest Save Many To One Untyped Object");
            trace("====================================");
            var obj:Object = new Object();
            obj.name = "Test Object";

            var mto:Object = new Object();
            mto.name = "Many To One";
            obj.mto = mto;

            var handle:int = em.save(obj, {name: "test"});

            var loadedObject:Object = em.loadDynamicObject("test", handle);
            assertEquals(loadedObject.mto.name, "Many To One");
        }

        public function testSaveOneToManyUntypedObject():void
        {
            trace("\nTest Save One To Many Untyped Object");
            trace("====================================");
            var obj:Object = new Object();
            obj.name = "Test Object";

            var myList:IList = new ArrayCollection();

            var x:Object = new Object();
            x.name = "First";
            var another:Object = new Object();
            another.type = "some type";
            x.another = another;
            myList.addItem(x);

            var y:Object = new Object();
            y.name = "Second";
            myList.addItem(y);
            obj.myList = myList;

            var handle:int = em.save(obj, {name: "test"});

            var loadedObject:Object = em.loadDynamicObject("test", handle);
            assertEquals(loadedObject.myList[0].another.type, "some type");
        }

        public function testRecursiveJoin():void
        {
            trace("\nTest Recursive Join");
            trace("===================");

            var g1:Gallery = new Gallery();
            g1.name = "A";

            var g2:Gallery = new Gallery();
            g2.name = "B";

            var g3:Gallery = new Gallery();
            g3.name = "C";
            g3.parent = g2;
            g2.parent = g1;
            em.save(g3);

            var loadedGallery:Gallery = em.loadItem(Gallery, g3.id) as Gallery;
            assertEquals(loadedGallery.name, "C");
            assertEquals(loadedGallery.parent.parent.name, "A");
        }

        public function testLazyLoading():void
        {
            trace("\nTest Lazy Loading");
            trace("=================");

            var car:Vehicle = new Vehicle();
            car.name = "Car";

            var engine:Part = new Part();
            engine.name = "Engine";
            car.parts.addItem(engine);

            var wheel:Part = new Part();
            wheel.name = "Wheel";
            car.parts.addItem(wheel);

            em.save(car);

            var loadedCar:Vehicle = em.load(Vehicle, car.id) as Vehicle;
            assertEquals(loadedCar.parts.length, 2);
        }

        public function testCriteriaAPI():void
        {
            trace("\nTest Criteria API");
            trace("=================");
            var organisation:Organisation = new Organisation();
            organisation.name = "Atlassian";
            em.save(organisation);

            var criteria:Criteria = em.createCriteria(Organisation);
            criteria.addLikeCondition("name", "lass").addSort("name", Sort.ASC);
            var result:ArrayCollection = em.fetchCriteria(criteria);
            var loadedOrganisation:Organisation = result[0] as Organisation;
            assertEquals(loadedOrganisation.name, "Atlassian");
        }

        public function testCriteriaAPI2():void
        {
            trace("\nTest Criteria API 2");
            trace("===================");
            var contact:Contact = new Contact();
            contact.name = "Mark";
            contact.emailAddr = "mark@codec.co.nz";
            em.save(contact);

            var criteria:Criteria = em.createCriteria(Contact);
            criteria.addJunction(criteria.createAndJunction().addLikeCondition("name", "M").addLikeCondition("emailAddr", "codec")).addSort("name");

            var result:ArrayCollection = em.fetchCriteria(criteria);
            var loadedContact:Contact = result[0] as Contact;
            assertEquals(loadedContact.name, "Mark");
        }

        public function testCriteriaAPI3():void
        {
            trace("\nTest Criteria API 3");
            trace("===================");
            var book:Book9= new Book9();
            book.name = "Todays Story";
            book.price = 5.2;
            book.published = new Date();
			em.save(book);

            var criteria:Criteria = em.createCriteria(Book9);
            criteria.addGreaterThanCondition("price", 5);
            criteria.addLessEqualsCondition("price", 6);
            criteria.addInCondition("name", ["Todays Story", "The Hitchhiker's Guide to the Galaxy"]);
            var result:ArrayCollection = em.fetchCriteria(criteria.addSort("name", Sort.DESC));

            var loadedBook:Book9 = result[0] as Book9;
            assertEquals(loadedBook.name, "Todays Story");
        }

        public function testCriteriaAPI4a():void
        {
            trace("\nTest Criteria API 4a");
            trace("===================");

            var status1:PartStatus11 = new PartStatus11();
            status1.value = "OK";
            var part1:Part11 = new Part11();
            part1.name = "part 1";
            part1.status = status1;
            em.save(part1);

            var status2:PartStatus11 = new PartStatus11();
            status2.value = "DEFECT";
            var part2:Part11 = new Part11();
            part2.name = "part 2";
            part2.status = status2;
            em.save(part2);

            var criteria:Criteria = em.createCriteria(Part11);
            criteria.addEqualsCondition("status.value", "OK");

            var result:ArrayCollection = em.fetchCriteria(criteria);

            assertEquals(result.length, 1);
            assertEquals((result[0] as Part11).name, "part 1");
        }

        public function testCriteriaAPI4b():void
        {
            // more complex than 4a test (deeper search tree, assigned column names)
            trace("\nTest Criteria API 4b");
            trace("===================");

            var book1:Book12 = new Book12();
            book1.id = IMPORT_KEY + 10;
            book1.title = "The Hitchhiker's Guide to the Galaxy";

            var room1:Room12 = new Room12();
            room1.description = "room #1";

            var owner1:KeyOwner12 = new KeyOwner12();
            owner1.name = "John Doe";

            room1.keyOwner = owner1;
            book1.location = room1;

            em.save(owner1); // for some reason, the code does not work without this, as the middle table (room12) will not get created
            em.save(book1);

            var book2:Book12 = new Book12();
            book2.id = IMPORT_KEY + 11;
            book2.title = "The Restaurant at the End of the Universe";

            var room2:Room12 = new Room12();
            room2.description = "room #2";

            var owner2:KeyOwner12 = new KeyOwner12();
            owner2.name = "Jane Doe";

            room2.keyOwner = owner2;
            book2.location = room2;

            em.save(book2);

            var book3:Book12 = new Book12();
            book3.id = IMPORT_KEY + 12;
            book3.title = "Todays Story";

            var room3:Room12 = new Room12();
            room3.description = "room #3";

            room3.keyOwner = owner1;
            book3.location = room3;

            em.save(book3);

            var criteria:Criteria = em.createCriteria(Book12);
            criteria.addEqualsCondition("location.keyOwner.name", "John Doe");

            var result:ArrayCollection = em.fetchCriteria(criteria);

            assertEquals(result.length, 2);
            assertEquals((result[0] as Book12).title, "The Hitchhiker's Guide to the Galaxy");
        }

        public function testAssignedIdStrategy():void
        {
            trace("\nTest Assigned ID Strategy");
            trace("=========================");
            var year:Year = new Year();
            year.year = 1989;
            em.save(year);
            var loadedYear:Year = em.load(Year, 1989) as Year;
            assertEquals(loadedYear.year, 1989);
        }

        public function testAssignedIdStrategyUsingString():void
        {
            trace("\nTest Assigned ID Strategy");
            trace("=========================");
            var setting:AppSetting = new AppSetting();
            setting.name = "hello";
            setting.value = "world";
            em.save(setting);
            var loadedSetting:AppSetting = em.load(AppSetting, "hello") as AppSetting;
            assertEquals(loadedSetting.value, "world");
        }

        public function simpleManyToManyRelationshipTest():void
        {
            var book1:Book = new Book();
            book1.name = "The Hitchhiker's Guide to the Galaxy";

            var book2:Book = new Book();
            book2.name = "The Restaurant at the End of the Universe";

            var author1:Author = new Author();
            author1.firstName = "Douglas";
            author1.lastName = "Adams";

            var books:ArrayCollection = new ArrayCollection();
            books.addItem(book1);
            books.addItem(book2);

            author1.books = books;

            assertEquals(book1.id, 0);
            assertEquals(book2.id, 0);
            assertEquals(author1.id, 0);

            em.save(author1);

            assertTrue(book1.id > 0);
            assertTrue(book2.id > 0);
            assertTrue(author1.id > 0);

            var allBooks:ArrayCollection = em.findAll(Book);
            assertTrue(allBooks.length == 2);

            var loadedBook:Book = em.loadItem(Book, book1.id) as Book;
            assertNotNull(loadedBook);

            var loadedAuthor:Author = em.loadItem(Author, author1.id) as Author;
            assertNotNull(loadedAuthor);
        }

        public function testMappedSuperclass():void
        {
            trace("\nTest MappedSuperclass");
            trace("=======================");

            var user:User3 = new User3();
            user.id = 1;
            user.username = "user1";
            user.active = true;
            user.lastUpdateUser = null;
            em.save(user);

            var loadedUser:User3 = em.load(User3, user.id) as User3;
            assertNotNull(loadedUser);
        }

        public function testNullable():void
        {
            trace("\nTest Nullable");
            trace("=======================");

            var user:User3 = new User3();
            user.id = 2;
            user.username = "user2";
            // don't assign user.active()
            user.lastUpdateUser = null;

            try
            {
                em.save(user);
            }
            catch (e:Error)
            {
                // AssertionFailedError(e.message);
                trace(e.message);
            }
        }

        public function testManyToManyFindAll():void
        {
            trace("\nTest ManyToMany FindAll");
            trace("=======================");

            var sysUser:User4 = new User4();
            sysUser.id = IMPORT_KEY;

            var permissions:ArrayCollection = new ArrayCollection();
            var roleGroup:RoleGroup4 = new RoleGroup4(); // sys_group

            roleGroup.id = IMPORT_KEY;
            roleGroup.roleGroupName = "groupRole 1";

            var roles:ArrayCollection = new ArrayCollection();
            var role:Role4 = new Role4(); // sys_role

            role.id = IMPORT_KEY;
            role.roleName = "Role 2";

            roles.addItem(role);

            roleGroup.roles = roles;

            permissions.addItem(roleGroup);
            sysUser.permissions = permissions;

            sysUser.username = "import";

            em.save(sysUser);
            // import user (end)

            trace("user was saved");

            var user2:User4 = em.load(User4, sysUser.id) as User4;
            assertNotNull(user2);

            trace("user was loaded");

            var roleGrp2:RoleGroup4 = em.load(RoleGroup4, roleGroup.id) as RoleGroup4;
            assertNotNull(roleGrp2);

            var roleGroups:ArrayCollection = em.findAll(RoleGroup4);
            assertEquals(roleGroups.length, 1);
        }

        public function testUpperCaseDatabase():void
        {
            trace("\nTest UpperCase Database");
            trace("=======================");

            // create the database tables, that have the same columns as they would be generated by FlexORM, but in uppercase
            var sqlCommand:String;
            sqlCommand =
                                        "CREATE TABLE IF NOT EXISTS MAIN.SYS_USER7(ID REAL PRIMARY KEY, USERNAME TEXT, CREATED_AT DATE, MARKED_FOR_DELETION BOOLEAN, UPDATED_AT DATE);";
            em.query(sqlCommand);
            sqlCommand =
                                        "CREATE TABLE IF NOT EXISTS MAIN.SYS_GROUP7(ID REAL PRIMARY KEY, NAME TEXT, CREATED_AT DATE, MARKED_FOR_DELETION BOOLEAN, UPDATED_AT DATE);";
            em.query(sqlCommand);
            sqlCommand =
                                        "CREATE TABLE IF NOT EXISTS MAIN.SYS_ROLE7(ID REAL PRIMARY KEY, NAME TEXT, CREATED_AT DATE, MARKED_FOR_DELETION BOOLEAN, UPDATED_AT DATE);";
            em.query(sqlCommand);
            sqlCommand = "CREATE TABLE IF NOT EXISTS MAIN.SYS_USER_GROUP7(PERMISSIONS_ID INTEGER, SYS_USER_ID INTEGER);";
            em.query(sqlCommand);
            sqlCommand = "CREATE TABLE IF NOT EXISTS MAIN.SYS_GROUP_ROLE7(ROLES_ID INTEGER, SYS_GROUP_ID INTEGER);";
            em.query(sqlCommand);

            var sysUser:User7 = new User7();
            sysUser.id = IMPORT_KEY;

            var permissions:ArrayCollection = new ArrayCollection();
            var roleGroup:RoleGroup7 = new RoleGroup7(); // sys_group

            roleGroup.id = IMPORT_KEY;
            roleGroup.roleGroupName = "groupRole 1";

            var roles:ArrayCollection = new ArrayCollection();
            var role:Role7 = new Role7(); // sys_role

            role.id = IMPORT_KEY;
            role.roleName = "Role 2";

            roles.addItem(role);

            roleGroup.roles = roles;

            permissions.addItem(roleGroup);
            sysUser.permissions = permissions;

            sysUser.username = "import";

            em.save(sysUser);
            // import user (end)

            trace("user was saved");

            var user2:User7 = em.load(User7, sysUser.id) as User7;
            assertNotNull(user2);
            assertEquals(user2.permissions.length, 1);

            trace("user was loaded (with Permissions)");

            var roleGrp2:RoleGroup7 = em.load(RoleGroup7, roleGroup.id) as RoleGroup7;
            assertNotNull(roleGrp2);
            assertEquals(roleGrp2.roles.length, 1);

            var roleGroups:ArrayCollection = em.findAll(RoleGroup7);
            assertEquals(roleGroups.length, 1);
        }

        public function testManyToManyAssocTable():void
        {
            trace("\nTest ManyToMany AssocTable");
            trace("=======================");

            var sysUser:User10 = new User10();
            sysUser.id = IMPORT_KEY;

            var permissions:ArrayCollection = new ArrayCollection();
            var roleGroup:RoleGroup10 = new RoleGroup10(); // sys_group

            roleGroup.id = IMPORT_KEY;
            roleGroup.roleGroupName = "groupRole 1";

            permissions.addItem(roleGroup);
            sysUser.permissions = permissions;

            sysUser.username = "import";

            em.save(sysUser);
            // import user (end)

            // save the same entry again (should only cause update statements)
            em.save(sysUser);

            // test column names of association table (configured by joinColumn and inverseJoinColumn)
            var assocTableContent:Object = em.query("SELECT * FROM sys_user_group10");
            var expectedResultFound:Boolean = (assocTableContent is Array);

            if (expectedResultFound)
            {
                var assocTableContentArray:Array = assocTableContent as Array;

                expectedResultFound = (assocTableContentArray.length == 1); // there should be only one entry!

                if (expectedResultFound)
                {
                    var firstAssocTableContentElement:* = assocTableContentArray[0];
                    trace(firstAssocTableContentElement.toString());
                    expectedResultFound = expectedResultFound && (firstAssocTableContentElement.hasOwnProperty('permissions_id'));
                    expectedResultFound = expectedResultFound && (firstAssocTableContentElement.hasOwnProperty('sys_user_id'));
                }
            }
            assertTrue(expectedResultFound);
        }

        public function testViewPresent():void
        {
            trace("\nTest View Present");
            trace("=======================");

            var sysUser:User4 = new User4();
            sysUser.id = IMPORT_KEY;
            sysUser.username = "import";

            em.save(sysUser);

            trace("user was saved");

            var sqlCommand:String = "CREATE VIEW vuser4 AS SELECT id, username FROM sys_user4;"
            em.query(sqlCommand);

            var vUser1:UserLight4 = em.load(UserLight4, IMPORT_KEY) as UserLight4;
            assertNotNull(vUser1);

            var vUser2:UserLightView4 = em.load(UserLightView4, IMPORT_KEY) as UserLightView4;
            assertNotNull(vUser2);
        }

        public function testViewAsManyToManyAssocTable():void
        {
            trace("\nTest View as ManyToMany AssocTable");
            trace("=======================");

            var sysUser:User8 = new User8();
            sysUser.id = IMPORT_KEY;
            sysUser.username = "import";

            var permissions:ArrayCollection = new ArrayCollection();
            var roleGroup:RoleGroup8 = new RoleGroup8(); // sys_group

            roleGroup.id = IMPORT_KEY;
            roleGroup.roleGroupName = "groupRole 1";

            permissions.addItem(roleGroup);
            sysUser.permissions = permissions;

            em.save(sysUser);

            trace("user was saved");

            var sqlCommand:String =
                                        "CREATE VIEW vSYS_USER_GROUP8 AS SELECT sys_user_id as sys_user_id_fromView, permissions_id as permissions_id_fromView FROM SYS_USER_GROUP8;"
            em.query(sqlCommand);

            var sysUserFromView:User8FromView = em.load(User8FromView, sysUser.id) as User8FromView;
            assertNotNull(sysUserFromView);
            assertEquals(sysUserFromView.permissions_fromView.length, 1);
        }

        public function testFillEnum2():void
        {
            trace("\nTest Fill Enum 2");
            trace("=======================");

            const ARRAY_LEN:int = 10;

            var array:Array = new Array(ARRAY_LEN);

            for (var i:int = 0; i < ARRAY_LEN; i++)
            {
                var resVO:ResultVO = new ResultVO();
                resVO.answer_id = i + 100;
                resVO.user_id = i + 100;
                array[i] = resVO;
            }
            ArrayStore.saveSync(em, array);

            var loadedId:int = ARRAY_LEN / 2;
            var arrItem:ResultVO = em.load(ResultVO, loadedId) as ResultVO;
            assertEquals(arrItem.answer_id, loadedId - 1 + 100);
        }

        public function testSaveOneToOne():void
        {
            trace("\nTest Save One To One");
            trace("======================");

            var employee1:Employee6 = new Employee6();
            employee1.name = "Employee 1";

            var detail1:EmployeeDetail6 = new EmployeeDetail6();
            detail1.primaryAccount = "user1";

            employee1.employeeDetail = detail1;

            var obj1:* = em.save(employee1);

            var loadedEmployee1:Employee6 = em.load(Employee6, obj1) as Employee6;
            assertEquals(loadedEmployee1.name, employee1.name);

            var loadedEmployeeDetail1:EmployeeDetail6 = em.load(EmployeeDetail6, loadedEmployee1.employeeDetail.id) as EmployeeDetail6;
            assertEquals(loadedEmployeeDetail1.primaryAccount, detail1.primaryAccount);

            var employee2:Employee6 = new Employee6();
            employee2.name = "Employee 2";

            var detail2:EmployeeDetail6 = new EmployeeDetail6();
            detail2.primaryAccount = "user2";

            employee2.employeeDetail = detail2;

            var obj2:* = em.save(employee2);

            var loadedEmployee2:Employee6 = em.load(Employee6, obj2) as Employee6;
            assertEquals(loadedEmployee2.name, employee2.name);
        }
    }
}
