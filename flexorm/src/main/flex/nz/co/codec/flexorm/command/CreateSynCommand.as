package nz.co.codec.flexorm.command
{
    import flash.data.SQLColumnSchema;
    import flash.data.SQLConnection;
    import flash.data.SQLSchemaResult;
    import flash.data.SQLTableSchema;
    import flash.errors.SQLError;

    import mx.collections.ArrayCollection;
    import mx.utils.StringUtil;

    import nz.co.codec.flexorm.metamodel.IDStrategy;
    import nz.co.codec.flexorm.util.CollectionHelper;
    import nz.co.codec.flexorm.util.StringUtils;

    public class CreateSynCommand extends SQLCommand
    {
        private var _created:Boolean;

        private var _pk:String;

        private var _idColumn:String;

        private var _isTableCreationWanted:Boolean;

        public function CreateSynCommand(sqlConnection:SQLConnection, schema:String, table:String, debugLevel:int = 0
                                         , isTableCreationWanted:Boolean = true)
        {
            super(sqlConnection, schema, table, debugLevel);
            _isTableCreationWanted = isTableCreationWanted;
            _created = false;
        }

        public function setPrimaryKey(column:String, idStrategy:String, type:String):void
        {
            if (IDStrategy.UID == idStrategy || IDStrategy.ASSIGNED == idStrategy)
            {
                _pk = StringUtil.substitute("{0} {1} primary key", column, type);
            }
            else
            {
                _pk = StringUtil.substitute("{0} integer primary key autoincrement", column);
            }
            _idColumn = column;
            _changed = true;
        }

        override public function addColumn(column:String, type:String=null, table:String=null):void
        {
            _columns[column] = { type: type };
            _changed = true;
        }

        public function addForeignKey(
            column:String,
            type:String,
            constraintTable:String,
            constraintColumn:String):void
        {
            _columns[column] = {
                type      : type,
                constraint: {
                    table : constraintTable,
                    column: constraintColumn
                }
            };
            _changed = true;
        }

        override protected function prepareStatement():void
        {
            var sql:String = null;
            var existingColumns:ArrayCollection = getExistingColumns();
            if (existingColumns)
            {
                sql = buildAlterSQL(existingColumns);
                _created = true;
            }
            else
            {
                sql = buildCreateSQL();
            }

            if (sql && !_isTableCreationWanted)
            {
                throw new Error("Database table '" + _table + "' would require changes which is not desired!");
            }

            _statement.text = sql ? sql : "";

            _changed = false;
        }

        private function getExistingColumns():ArrayCollection
        {
            try
            {
                // @NOTE: SQLite does not distinguish between uppercase/lowercase table names,
                // however _sqlConnection.loadSchema(SQLTableSchema, _table) would do so
                _sqlConnection.loadSchema(SQLTableSchema);
                var schemaResult:SQLSchemaResult = _sqlConnection.getSchemaResult();
                for (var i:int = 0; i < schemaResult.tables.length; i++)
                {
                    if (StringUtils.stringsEqualCaseIgnored(schemaResult.tables[i].name, _table))
					{
						var existingColumns:ArrayCollection = new ArrayCollection();
                        for each (var column:SQLColumnSchema in schemaResult.tables[i].columns)
						{
							if (!column.primaryKey)
							{
								existingColumns.addItem(column.name);
							}
						}
						return existingColumns;
					}
                }
            }
            catch (e:SQLError) { }
            return null;
        }

        private function buildAlterSQL(existingColumns:ArrayCollection):String
        {
            var sql:String = "";
            for (var column:String in _columns)
            {
                if (column != _idColumn)	// cannot add idColumns later on
                {
                    // @NOTE: SQLite does not distinguish between uppercase/lowercase table names,
                    // existingColumns.contains(column) would not check for different cases
                    if (!CollectionHelper.itemIsContainedInListCaseIgnored(column, existingColumns))
					{
						sql += StringUtil.substitute("alter table {0}.{1} add {2} {3};" + SQL_STATEMENT_SEPARATOR,
							   _schema, _table, column, _columns[column].type);
					}
				}
            }
            return (sql.length > 0)? sql : null;
        }

        private function buildCreateSQL():String
        {
            var sql:String = StringUtil.substitute("create table if not exists {0}.{1}(", _schema, _table);
            if (_pk)
                sql += _pk + ",";

            for (var column:String in _columns)
            {
                sql += StringUtil.substitute("{0} {1},", column, _columns[column].type);
            }
            sql = sql.substring(0, sql.length - 1) + ");"; // remove last comma
            sql += SQL_STATEMENT_SEPARATOR;
            return sql;
        }

        override public function execute():void
        {
            if (_changed)
                prepareStatement();

            if (!_statement.text) // if _statement.text == null || ""
                return;

			executeSqlStatements();
        }

        public function executeTrigger():void
        {
            // Create foreign key constraint triggers
            if (!_created)
            {
                // you almost always get here - only if the table was changed and columns existed previously prevents this
                for (var column:String in _columns)
                {
                    var constraint:Object = _columns[column].constraint;
                    if (constraint)
                    {
                        new ConstraintInsertTriggerCommand(_sqlConnection, _schema, _table, column, constraint.table, constraint.column, _debugLevel).execute();
                        new ConstraintUpdateTriggerCommand(_sqlConnection, _schema, _table, column, constraint.table, constraint.column, _debugLevel).execute();
                        new ConstraintDeleteTriggerCommand(_sqlConnection, _schema, _table, column, constraint.table, constraint.column, _debugLevel).execute();
                    }
                }
            }
        }

        public function toString():String
        {
            return "CREATE " + _table + ": " + getStatementText();
        }

    }
}