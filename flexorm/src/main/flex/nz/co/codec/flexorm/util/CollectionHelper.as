package nz.co.codec.flexorm.util
{

    public class CollectionHelper
    {
        /**
         * check if an item the item is contained in the list (arbitrary type)
         */
        public static function itemIsContainedInListCaseIgnored(item:String, list:*):Boolean
        {
            for each (var element:String in list)
            {
                if (StringUtils.stringsEqualCaseIgnored(item, element))
                {
                    return true;
                }
            }
            return false;
        }
    }
}
