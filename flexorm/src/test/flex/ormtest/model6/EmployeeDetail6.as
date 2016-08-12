package ormtest.model6
{

    [Bindable]
    [Table(name = "employee_details6")]
    public class EmployeeDetail6
    {
        [Id]
        public var id:int;

        public var primaryAccount:String;

    }
}
