package ormtest.model6
{

    [Bindable]
    [Table(name = "employee6")]
    public class Employee6
    {
        [Id]
        public var id:int;

        public var name:String;

        [OneToOne(name = "employee_detail_6_id", nullable = true, lazy = "false", cascade = "all", orphanRemoval = true)]
        [ForeignKey(name = "FK_EMPLOYEE_EMPLOYEEDETAIL_")]
        public var employeeDetail:EmployeeDetail6;

    }
}
