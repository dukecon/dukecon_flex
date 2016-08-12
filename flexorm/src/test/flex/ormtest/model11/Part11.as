package ormtest.model11
{

    [Bindable]
    public class Part11
    {
        public var id:int;
        public var name:String;

        [ManyToOne]
        public var status:PartStatus11;
    }
}
