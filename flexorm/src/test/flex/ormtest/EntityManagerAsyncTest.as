package ormtest
{
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;

import flexunit.framework.TestCase;
import flexunit.framework.TestSuite;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.rpc.Responder;

import nz.co.codec.flexorm.EntityErrorEvent;
import nz.co.codec.flexorm.EntityEvent;
import nz.co.codec.flexorm.EntityManagerAsync;
import nz.co.codec.flexorm.criteria.Criteria;
import nz.co.codec.flexorm.criteria.Sort;
import nz.co.codec.flexorm.util.ArrayStore;

import ormtest.model.Contact;
import ormtest.model.Lesson;
import ormtest.model.Order;
import ormtest.model.Organisation;
import ormtest.model.Resource;
import ormtest.model.Role;
import ormtest.model.Schedule;
import ormtest.model.Student;
import ormtest.model2.Person;
import ormtest.model3.User3;
import ormtest.model5.ResultVO;

public class EntityManagerAsyncTest extends TestCase
    {
        private var em:EntityManagerAsync = EntityManagerAsync.instance;

        override public function setUp():void {
            var dbFile:File = File.userDirectory.resolvePath("flexorm_test.db");

            if (dbFile.exists)
            {
                dbFile.deleteFile();
            }

            em.openAsyncConnection(dbFile.nativePath, new Responder(function(event:SQLEvent):void
            {
                trace(this);
                /*                testRunner.test = suite();
                 testRunner.startTest();*/
            }, function(error:SQLErrorEvent):void
            {
                trace(error);
            }));
        }

        override public function tearDown():void
        {
            em.closeAsyncConnection(new Responder(function(event:SQLEvent):void
            {
                // em.deleteDBFile();
            }, function(error:SQLErrorEvent):void
            {
                trace(error);
            }));
        }


        public static function suite():TestSuite
        {
            EntityManagerAsync.instance.debugLevel = 1;
            var ts:TestSuite = new TestSuite();
            ts.addTest(new EntityManagerAsyncTest("testNullFindAll"));
            ts.addTest(new EntityManagerAsyncTest("testSaveSimpleObject"));
            ts.addTest(new EntityManagerAsyncTest("testFindAll"));
            ts.addTest(new EntityManagerAsyncTest("testGraphFindAll"));
            ts.addTest(new EntityManagerAsyncTest("testSaveManyToOneAssociation"));
            ts.addTest(new EntityManagerAsyncTest("testSaveOneToManyAssociations"));
            ts.addTest(new EntityManagerAsyncTest("testSaveManyToManyAssociation"));
            ts.addTest(new EntityManagerAsyncTest("testDelete"));
            ts.addTest(new EntityManagerAsyncTest("testCascadeSaveUpdate"));
            ts.addTest(new EntityManagerAsyncTest("testInheritance1"));
            ts.addTest(new EntityManagerAsyncTest("testInheritance2"));
            ts.addTest(new EntityManagerAsyncTest("testTransaction"));
            ts.addTest(new EntityManagerAsyncTest("testCompositeKey"));
            ts.addTest(new EntityManagerAsyncTest("testCompositeKeyOneToMany"));
            ts.addTest(new EntityManagerAsyncTest("testOneToManyIndexedCollection"));
            ts.addTest(new EntityManagerAsyncTest("testManyToManyIndexedCollection"));
            ts.addTest(new EntityManagerAsyncTest("testCriteriaAPI"));
            ts.addTest(new EntityManagerAsyncTest("testCriteriaAPI2"));

            ts.addTest(new EntityManagerAsyncTest("testMappedSuperclass"));

            ts.addTest(new EntityManagerAsyncTest("testFillEnum1"));
            ts.addTest(new EntityManagerAsyncTest("testFillEnum2"));

            return ts;
        }

        private const ENUM1_COUNT:int = 10;
        private const ENUM2_COUNT:int = 10;

        public function EntityManagerAsyncTest(methodName:String = null)
        {
            super(methodName);
        }

        public function testNullFindAll():void
        {
            trace("\nTest Null Find All");
            trace("==================");
            em.findAll(Organisation, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("findAll fired...");
                assertEquals(ev.data.length, 0);
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in select: " + e.message);
                trace(e.getStackTrace());
            }));
        }

        public function testSaveSimpleObject():void
        {
            trace("\nTest Save Simple Object");
            trace("=======================");
            var organisation:Organisation = new Organisation();
            organisation.name = "Codec Software Limited";
            em.save(organisation, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("save fired...");
                em.load(Organisation, Organisation(ev.data).id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("load fired...");
                    assertEquals(ev.data.name, "Codec Software Limited");
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace("Failed in load: " + e.message);
                    trace(e.getStackTrace());
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e.message);
                trace(e.getStackTrace());
            }));
        }

        public function testFindAll():void
        {
            trace("\nTest Find All");
            trace("=============");
            var organisation:Organisation = new Organisation();
            organisation.name = "Adobe";
            em.save(organisation, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("save fired...");
                em.findAll(Organisation, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("findAll fired...");
                    assertEquals(ev.data.length, 2);
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace("Failed in select: " + e.message);
                    trace(e.getStackTrace());
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e.message);
                trace(e.getStackTrace());
            }));
        }

        public function testGraphFindAll():void
        {
            trace("\nTest Graph Find All");
            trace("===================");
            var james:Contact = new Contact();
            james.name = "James";
            var jamesOrders:ArrayCollection = new ArrayCollection();
            var couch:Order = new Order();
            couch.item = "Couch";
            jamesOrders.addItem(couch);
            var desk:Order = new Order();
            desk.item = "Desk";
            jamesOrders.addItem(desk);
            james.orders = jamesOrders;
            em.save(james, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("save james fired...");
                var john:Contact = new Contact();
                john.name = "John";
                var johnRoles:ArrayCollection = new ArrayCollection();
                var developer:Role = new Role();
                developer.name = "Developer";
                johnRoles.addItem(developer);
                var tester:Role = new Role();
                tester.name = "Tester";
                johnRoles.addItem(tester);
                john.roles = johnRoles;
                em.save(john, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("save john fired...");
                    em.findAll(Contact, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        trace("findAll fired...");
                        assertEquals(ev.data.length, 2);
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        trace("Failed in select: " + e.message);
                        trace(e.getStackTrace());
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace(e);
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e.message);
                trace(e.getStackTrace());
            }));
        }

        public function testSaveManyToOneAssociation():void
        {
            trace("\nTest Save Many To One Association");
            trace("=================================");
            var organisation:Organisation = new Organisation();
            organisation.name = "Apple";
            // since Organisation has cascade="none" on Contact
            em.save(organisation, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("save Organisation fired...");
                var contact:Contact = new Contact();
                contact.name = "Steve";
                contact.organisation = ev.data as Organisation;
                em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("save Contact fired...");
                    em.load(Contact, Contact(ev.data).id, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        trace("load fired...");
                        var loadedContact:Contact = ev.data as Contact;
                        assertNotNull(loadedContact);
                        assertNotNull(loadedContact.organisation);
                        assertEquals(loadedContact.organisation.name, "Apple");
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        trace("Failed in load: " + e);
                        trace(e.getStackTrace());
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace("Failed in save Contact: " + e);
                    trace(e.getStackTrace());
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in save Organisation: " + e);
                trace(e.getStackTrace());
            }));
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
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("save fired...");
                em.load(Contact, ev.data.id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("load fired...");
                    var loadedContact:Contact = ev.data as Contact;
                    assertEquals(loadedContact.orders.length, 2);
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace("Failed in load: " + e);
                    trace(e.getStackTrace());
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e);
                trace(e.getStackTrace());
            }));
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
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                em.load(Contact, Contact(ev.data).id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    var loadedContact:Contact = ev.data as Contact;
                    assertEquals(loadedContact.roles.length, 2);
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testDelete():void
        {
            trace("\nTest Delete");
            trace("===========");
            var organisation:Organisation = new Organisation();
            organisation.name = "Datacom";
            em.save(organisation, new Responder(addAsync(function(ev:EntityEvent):void
            {
                em.remove(ev.data as Organisation, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    em.load(Organisation, organisation.id, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        assertNull(ev.data);
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        assertNotNull(e);
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
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
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                var savedContact:Contact = ev.data as Contact;
                var orderId:int = savedContact.orders[0].id;

                // verify that cascade save-update works
                assertTrue(orderId > 0);

                em.remove(contact, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    // verify that cascade delete is not in effect

                    // !!! Yes, but foreign key constraint violation is
                    // so FK constraint has been switched off using constrain="false"
                    em.load(Order, orderId, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        var loadedOrder:Order = ev.data as Order;
                        assertEquals(loadedOrder.item, "Bach");
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        throw e;
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testInheritance1():void
        {
            trace("\nTest Inheritance 1");
            trace("==================");
            var person:Person = new Person();
            person.emailAddr = "person@acme.com";
            em.save(person, new Responder(addAsync(function(ev:EntityEvent):void
            {
                em.load(Person, Person(ev.data).id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    var loadedPerson:Person = ev.data as Person;
                    assertEquals(loadedPerson.emailAddr, "person@acme.com");
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testInheritance2():void
        {
            trace("\nTest Inheritance 2");
            trace("==================");
            var contact:Contact = new Contact();
            contact.name = "Bill";
            contact.emailAddr = "bill@ms.com";
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                em.load(Contact, Contact(ev.data).id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    var loadedContact:Contact = ev.data as Contact;
                    assertEquals(loadedContact.emailAddr, "bill@ms.com");

                    em.load(Person, loadedContact.id, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        var loadedPerson:Person = ev.data as Person;
                        assertEquals(loadedPerson.emailAddr, "bill@ms.com");
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        trace(e.message);
                        trace(e.getStackTrace());
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));

                //                    em.load(Person, Person(ev.data).id, new Responder(
                //


                //                        addAsync(function(ev:EntityEvent):void
                //                        {
                //                            var loadedPerson:Person = ev.data as Person;
                //                            assertEquals(loadedPerson.emailAddr, "bill@ms.com");
                //                        }, 1500),
                //


                //                        function(e:EntityError):void
                //                        {
                //                            trace(e.message)
                //                            trace(e.getStackTrace());
                //                        }
                //                    ));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testTransaction():void
        {
            trace("\nTest Transactions");
            trace("=================");

            em.startTransaction(new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("successful transaction start");
                var organisation:Organisation = new Organisation();
                organisation.name = "Google";
                em.save(organisation, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("saved organisation '" + organisation.name + "'");
                    var contact:Contact = new Contact();
                    contact.name = "Sergey";
                    contact.organisation = organisation;
                    em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        trace("saved contact '" + contact.name + "' for organisation '" + organisation.name + "'");
                        em.remove(organisation, new Responder(addAsync(function(ev:EntityEvent):void
                        {
                            trace("trying to end the transaction");
                            em.endTransaction(new Responder(addAsync(function(ev:EntityEvent):void
                            {
                                trace("transaction commit successful?");
                            }, 1500, null, function(e:*):void
                            {
                                trace("transaction commit failed within timeframe!");
                                assertNull(e); // transaction was already gone, so this is to be expected
                            }), function(e:EntityErrorEvent):void
                            {
                                trace("transaction commit failed:");
                                trace(e);
                                // The transaction is expected to fail with a
                                // foreign key constraint violation
                                assertNotNull(e);
                            }));
                        }, 1500), function(e:EntityErrorEvent):void
                        {
                            // FIXME
                            // the remove operation is failing and responding before commit is called.
                            // Need to check if the sqlConnection is staying in transaction.

                            // No it is not!
                            // The FK constraint triggers will end the transaction before commit is called.

                            trace("remove operation failed:");
                            trace(e);
                            assertNotNull(e);
                            throw e;
                        }));
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        trace(e);
                        throw e;
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace(e);
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace(e);
                throw e;
            }));
        }

        public function testCompositeKey():void
        {
            trace("\nTest Composite Key");
            trace("==================");
            var student:Student = new Student();
            student.name = "Mark";
            em.save(student, new Responder(addAsync(function(ev:EntityEvent):void
            {
                var stud:Student = ev.data as Student;
                trace("saved Student: " + stud.id + " " + stud.name);
                var lesson:Lesson = new Lesson();
                lesson.name = "Piano";
                em.save(lesson, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    var schedule:Schedule = new Schedule();
                    schedule.student = stud;
                    schedule.lesson = ev.data as Lesson;
                    trace("saved Lesson: " + schedule.lesson.id + " " + schedule.lesson.name);
                    var today:Date = new Date();
                    schedule.lessonDate = today;
                    em.save(schedule, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        var sched:Schedule = ev.data as Schedule;
                        trace("saved Schedule: " + sched.lessonDate);
                        em.loadItemByCompositeKey(Schedule, [sched.student, sched.lesson], new Responder(addAsync(function(ev:EntityEvent):void
                        {
                            var loadedSchedule:Schedule = ev.data as Schedule;
                            trace("loaded Schedule: " + loadedSchedule.lessonDate);
                            assertEquals(loadedSchedule.lessonDate.fullYear, today.fullYear);
                            assertEquals(loadedSchedule.lessonDate.month, today.month);
                            assertEquals(loadedSchedule.lessonDate.date, today.date);
                        }, 1500), function(e:EntityErrorEvent):void
                        {
                            throw e;
                        }));
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        throw e;
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testCompositeKeyOneToMany():void
        {
            trace("\nTest Composite Key with One-to-many");
            trace("===================================");
            var student:Student = new Student();
            student.name = "Shannon";
            em.save(student, new Responder(addAsync(function(ev:EntityEvent):void
            {
                var stud:Student = ev.data as Student;
                trace("saved Student: " + stud.id + " " + stud.name);
                var lesson:Lesson = new Lesson();
                lesson.name = "Viola";
                em.save(lesson, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    var schedule:Schedule = new Schedule();
                    schedule.student = stud;
                    schedule.lesson = ev.data as Lesson;
                    trace("saved Lesson: " + schedule.lesson.id + " " + schedule.lesson.name);
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

                    em.save(schedule, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        var sched:Schedule = ev.data as Schedule;
                        trace("saved Schedule: " + sched.lessonDate);
                        em.loadItemByCompositeKey(Schedule, [sched.student, sched.lesson], new Responder(addAsync(function(ev:EntityEvent):void
                        {
                            var loadedSchedule:Schedule = ev.data as Schedule;
                            trace("loaded Schedule: " + loadedSchedule.lessonDate);
                            assertEquals(loadedSchedule.resources.length, 2);
                        }, 1500), function(e:EntityErrorEvent):void
                        {
                            throw e;
                        }));
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        throw e;
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
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
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("saved contact");
                em.load(Contact, ev.data.id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("loaded contact");
                    var loadedContact:Contact = ev.data as Contact;
                    assertEquals(loadedContact.orders[1].item, "iPhone");

                    var ordersList:IList = loadedContact.orders;
                    ordersList.addItemAt(ordersList.removeItemAt(1), 0);
                    em.save(loadedContact, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        trace("saved contact with reordered orders collection");
                        em.load(Contact, contact.id, new Responder(addAsync(function(ev:EntityEvent):void
                        {
                            trace("reloaded contact");
                            var reloadedContact:Contact = ev.data as Contact;
                            assertEquals(reloadedContact.orders[1].item, "Macbook");
                        }, 1500), function(e:EntityErrorEvent):void
                        {
                            throw e;
                        }));
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        trace(e.message);
                        throw e;
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
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
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("saved contact");
                em.load(Contact, ev.data.id, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    trace("loaded contact");
                    var loadedContact:Contact = ev.data as Contact;
                    assertEquals(loadedContact.roles[1].name, "Sparky");

                    var roleList:IList = loadedContact.roles;
                    roleList.addItemAt(roleList.removeItemAt(1), 0);
                    em.save(loadedContact, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        trace("saved contact with reordered roles collection");
                        em.load(Contact, ev.data.id, new Responder(addAsync(function(ev:EntityEvent):void
                        {
                            var reloadedContact:Contact = ev.data as Contact;
                            trace("reloaded contact");
                            assertEquals(reloadedContact.roles[1].name, "Carpenter");
                        }, 1500), function(e:EntityErrorEvent):void
                        {
                            throw e;
                        }));
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        throw e;
                    }));
                }, 1500), function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testCriteriaAPI():void
        {
            trace("\nTest Criteria API");
            trace("=================");
            var organisation:Organisation = new Organisation();
            organisation.name = "Atlassian";
            em.save(organisation, new Responder(addAsync(function(ev:EntityEvent):void
            {
                em.createCriteria(Organisation, new Responder(

                    // not using addAsync. createCriteria, in this case,
                    // calls back the responder synchronously (since the
                    // Organisation entity has already been introspected).
                    // AsyncTestHelper.startAsync is not getting called
                    // before AsyncTestHelper.handleEvent.
                                            function(ev:EntityEvent):void
                                            {
                                                var criteria:Criteria = ev.data as Criteria;
                                                criteria.addLikeCondition("name", "lass").addSort("name", Sort.ASC);
                                                em.fetchCriteria(criteria, new Responder(addAsync(function(ev:EntityEvent):void
                                                {
                                                    var loadedOrganisation:Organisation = ev.data[0] as Organisation;
                                                    trace("loaded organisation");
                                                    assertEquals(loadedOrganisation.name, "Atlassian");
                                                }, 1500), function(e:EntityErrorEvent):void
                                                {
                                                    throw e;
                                                }));
                                            }, function(e:EntityErrorEvent):void
                                            {
                                                throw e;
                                            }));
            }, 1500), function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testCriteriaAPI2():void
        {
            trace("\nTest Criteria API 2");
            trace("===================");
            var contact:Contact = new Contact();
            contact.name = "Mark";
            contact.emailAddr = "mark@codec.co.nz";
            em.save(contact, new Responder(addAsync(function(ev:EntityEvent):void
            {
                em.createCriteria(Contact, new Responder(function(ev:EntityEvent):void
                {
                    var criteria:Criteria = ev.data as Criteria;
                    criteria.addJunction(criteria.createAndJunction().addLikeCondition("name", "M").addLikeCondition("emailAddr", "codec")).addSort("name");
                    em.fetchCriteria(criteria, new Responder(addAsync(function(ev:EntityEvent):void
                    {
                        var loadedContact:Contact = ev.data[0] as Contact;
                        trace("loaded contact");
                        assertEquals(loadedContact.name, "Mark");
                    }, 1500), function(e:EntityErrorEvent):void
                    {
                        throw e;
                    }));
                }, function(e:EntityErrorEvent):void
                {
                    throw e;
                }));
            }, 1500)
                            , function(e:EntityErrorEvent):void
            {
                throw e;
            }));
        }

        public function testMappedSuperclass():void
        {
            trace("\nTest MappedSuperclass");
            trace("=======================");

            var user:User3 = new User3();
            user.id = 1;
            user.username = "user1";
            user.lastUpdateUser = null;
            em.save(user, new Responder(addAsync(function(ev:EntityEvent):void
            {
                trace("save fired...");
                assertNotNull(ev.data);
            /*
               em.load(User3, User3(ev.data).id, new Responder(addAsync(function(ev:EntityEvent):void
               {
               trace("load fired...");
               assertNotNull(ev.data);
               assertEquals(User3(ev.data).username, "user1");
               }, 1500), function(e:EntityErrorEvent):void
               {
               trace("Failed in load: " + e.message);
               trace(e.getStackTrace());
               }));
             */
            }, 1500), function(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e.message);
                trace(e.getStackTrace());
            }));
        }

        public function testFillEnum1():void
        {
            trace("\nTest Fill Enum 1");
            trace("=======================");

            var i:int = 0;
            storeResultVO();

            function storeResultVO():void
            {
                var resVO:ResultVO = new ResultVO();
                resVO.answer_id = i;
                resVO.user_id = i;
                em.save(resVO, new Responder(addAsync(onSave, 1500), onError));
            }

            function onSave(ev:EntityEvent = null):void
            {
                trace("save fired... (j=" + i + ")");
                var savedResultVO:ResultVO = ev.data as ResultVO;
                assertNotNull(savedResultVO);
                trace("savedResultVO.id: " + savedResultVO.id);

                i++;

                if (i < ENUM1_COUNT)
                {
                    storeResultVO();
                }
            }

            function onError(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e.message);
                trace(e.getStackTrace());
            }
        }

        public function testFillEnum2():void
        {
            trace("\nTest Fill Enum 2");
            trace("=======================");

            const ENUM2_OFFSET:int = 100;

            var array:Array = new Array(ENUM2_COUNT);

            for (var i:int = 0; i < ENUM2_COUNT; i++)
            {
                var resVO:ResultVO = new ResultVO();
                resVO.answer_id = i + ENUM2_OFFSET;
                resVO.user_id = i + ENUM2_OFFSET;
                array[i] = resVO;
            }
            ArrayStore.saveAsync(em, array, new Responder(addAsync(onResult, 1500), onError));

            function onResult(ev:EntityEvent = null):void
            {
                em.findAll(ResultVO, new Responder(addAsync(function(ev:EntityEvent):void
                {
                    assertEquals(ev.data.length, ENUM1_COUNT + ENUM2_COUNT);
                }, 1500), function(e:EntityErrorEvent):void
                {
                    trace("Failed in select: " + e.message);
                    trace(e.getStackTrace());
                }));
            }

            function onError(e:EntityErrorEvent):void
            {
                trace("Failed in save: " + e.message);
                trace(e.getStackTrace());
            }
        }
    }
}
