package ormtest.model5
{

    [Bindable]
    [Table(name = "ResultVO")]
    public class ResultVO
    {
        [Id]
        public var id:int;

        public var user_id:int;

        public var answer_id:int;

        public function ResultVO()
        {
        }

    }
}
