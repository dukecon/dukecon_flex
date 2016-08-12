package nz.co.codec.flexorm.criteria
{
    import nz.co.codec.flexorm.metamodel.Association;
    import nz.co.codec.flexorm.metamodel.Entity;

    public class Criteria
    {
        private var _entity:Entity;

        private var _filters:Array;

        private var _joinFilters:Array;

        private var _sorts:Array;

        private var _params:Object;

        public function Criteria(entity:Entity)
        {
            _entity = entity;
            _filters = [];
            _joinFilters = [];
            _sorts = [];
            _params = {};
        }

        public function get entity():Entity
        {
            return _entity;
        }

        public function get filters():Array
        {
            return _filters;
        }

        public function get joinFilters():Array
        {
            return _joinFilters;
        }

        public function get sorts():Array
        {
            return _sorts;
        }

        public function get params():Object
        {
            return _params;
        }

        public function addSort(property:String, order:String=null):Criteria
        {
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _sorts.push(new Sort(column.table, column.column, order));
            }
            return this;
        }

        public function createAndJunction():Junction
        {
            return Junction.and(_entity);
        }

        public function createOrJunction():Junction
        {
            return Junction.or(_entity);
        }

        public function addJunction(junction:Junction):Criteria
        {
            _filters.push(junction);
            return this;
        }

        public function addEqualsCondition(property:String, value:Object):Criteria
        {
			return addRelationCondition(property, "=", value);
        }

        public function addNotEqualsCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, "<>", value);
        }

        public function addGreaterThanCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, ">", value);
        }

        public function addNotGreaterThanCondition(property:String, value:Object):Criteria
            {
            return addRelationCondition(property, ">", value, true);
            }

        public function addGreaterEqualsCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, ">=", value);
        }

        public function addNotGreaterEqualsCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, ">=", value, true);
        }

        public function addLessThanCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, "<", value);
        }

        public function addNotLessThanCondition(property:String, value:Object):Criteria
            {
            return addRelationCondition(property, "<", value, true);
            }

        public function addLessEqualsCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, "<=", value);
        }

        public function addNotLessEqualsCondition(property:String, value:Object):Criteria
        {
            return addRelationCondition(property, "<=", value, true);
        }

        public function addLikeCondition(property:String, str:String):Criteria
        {
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _filters.push(new LikeCondition(column.table, column.column, str));
            }
            else
            {
                trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
            }
            return this;
        }

        public function addNotLikeCondition(property:String, str:String):Criteria
        {
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _filters.push(new LikeCondition(column.table, column.column, str, true));
            }
            else
            {
                trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
            }
            return this;
        }

		public function addInCondition(property:String, arr:Array):Criteria
		{
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _filters.push(new InCondition(column.table, column.column, arr));
            }
            else
            {
                trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
            }
            return this;			
		}

		public function addNotInCondition(property:String, arr:Array):Criteria
		{
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _filters.push(new InCondition(column.table, column.column, arr, true));
            }
            else
            {
                trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
            }
            return this;			
		}

        public function addNullCondition(property:String):Criteria
        {
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _filters.push(new NullCondition(column.table, column.column));
            }
            else
            {
                trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
            }
            return this;
        }

        public function addNotNullCondition(property:String):Criteria
        {
            var column:Object = _entity.getColumn(property);

            // TODO: what if the column is not found?
            if (column)
            {
                _filters.push(new NullCondition(column.table, column.column, true));
            }
            else
            {
                trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
            }
            return this;
        }

        private function addRelationCondition(property:String, relation:String, value:Object, negated:Boolean = false):Criteria
        {
            var paramName:String;
            var column:Object;

            if (property.indexOf(".") == -1)
            {
                column = _entity.getColumn(property);

                // TODO: what if the column is not found?
                if (column)
                {
                    paramName = property + _filters.length.toString();
                    _filters.push(new RelationCondition(column.table, column.column, relation, paramName, negated));
                    _params[paramName] = value;
                }
                else
                {
                    trace("*** CAUTION: column '" + property + "' not found in entity '" + _entity.name + "' ***");
                }
            }
            else
            {
                var props:Array = property.split(".");
                paramName = props.join("_") + _joinFilters.length.toString();

                var joins:Object = {};
                var relatedEntity:Entity = _entity; // init loop
                var last_join_index:uint = props.length - 1;

                for (var i:uint = 0; i < last_join_index; i++)
                {
                    var assoc:Association = relatedEntity.getAssociation(props[i]);
                    relatedEntity = assoc.associatedEntity;

                    var table:String = relatedEntity.table;
                    var pk:String = assoc.fkColumn;
                    var fk:String = relatedEntity.pk.column;

                    joins[table] = {};
                    joins[table][fk] = pk;
                }

                column = relatedEntity.getColumn(props[last_join_index]);

                _joinFilters.push(new DottedRelationCondition(column.table, column.column, joins, relation, paramName, negated));
                _params[paramName] = value;
            }
            return this;
        }
   }
}
