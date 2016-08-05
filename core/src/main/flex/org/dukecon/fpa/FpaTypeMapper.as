/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.fpa {
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;

import org.dukecon.model.Identifyable;

public class FpaTypeMapper {

    private var _type:Class;
    private var _tableName:String;
    private var _properties:Array;

    public function FpaTypeMapper(type:Class) {
        _type = type;
        var typeDescription:XML = describeType(_type);

        // All types we want to persist have to implement the Identifyable interface.
        // So before doing anything else, we have to check if the current type implements
        // this.
        var identifyableTypeName:String = getQualifiedClassName(Identifyable);
        var implementsIdentifyable:Boolean = false;
        for each(var interf:String in typeDescription..implementsInterface.@type) {
            if(interf == identifyableTypeName) {
                implementsIdentifyable = true;
                break;
            }
        }
        if(!implementsIdentifyable) {
            throw new Error("Type does not implement Identifyable");
        }

        // Determine the database name for this type.
        var typeName:String = getQualifiedClassName(type);
        if(typeName.indexOf("::") != -1) {
            typeName = typeName.split("::")[1];
        }
        _tableName = convertToDatabaseName(typeName);

        // Determine the fields for this type.
        _properties = getProperties(type);
    }

    public function get type():Class {
        return _type;
    }

    public function get tableName():String {
        return _tableName;
    }

    public function get fields():Object {
        return null;
    }

    /**
     * Converts a typical camel case string into an uppercase string
     * in which the parts are joined by '_'.
     * @param name Camel-Case input string
     * @return database version of the input string
     */
    public static function convertToDatabaseName(name:String):String {
        var r:RegExp = /(^[a-z]|[A-Z0-9])[a-z]*/g;
        var result:Array = name.match(r);
        return result.join("_").toUpperCase();
    }

    private static function getProperties(type:Class, namePrefix:String = null):Array {
        var properties:Array = [];
        var typeDescription:XML = describeType(type);
        for each(var property:XML in typeDescription..accessor.(@access=="readwrite")) {
            var propertyName:String = property.@name;
            var propertyTypeName:String = property.@type;
            var propertyType:Class = getDefinitionByName(propertyTypeName.replace("::", ".")) as Class;
            var relationType:String = property.metadata.(@name=="Relation").arg.(@key=="relationType").@value;
            var remoteTypeName:String = property.metadata.(@name=="Relation").arg.(@key=="remoteType").@value;
            if(remoteTypeName && remoteTypeName.indexOf(" ") != -1) {
                remoteTypeName = remoteTypeName.split(" ")[1];
            }
            var remoteType:Class;
            if("java.lang.Object" == remoteTypeName) {
                remoteType = Object;
            } else {
                try {
                    remoteType = (remoteTypeName) ? getDefinitionByName(remoteTypeName) as Class : null;
                } catch(e:Error) {
                    throw new Error("Failed to load class '" + remoteTypeName + "'. " +
                            "Eventually this class needs to be referenced or manually included in the " +
                            "compiler configuration.")
                }
            }

            var field:FpaField = new FpaField();
            field.name = propertyName;
            field.type = propertyType;
            field.dbName = ((namePrefix) ? namePrefix.toUpperCase() + "_" : "") + propertyName.toUpperCase();

            // This is some sort of relation.
            if(relationType) {
                switch (relationType) {
                        // We will embed the fields of ONE_TO_ONE relations
                    case "ONE_TO_ONE":
                        var embedProperties:Array = getProperties(propertyType, field.dbName);
                        properties.push(embedProperties);
                        break;
                        // This is a collection of items
                        // (The work has to be done on the "MANY_TO_ONE" side)
                    case "ONE_TO_MANY":
                        break;
                        // This is the back reference to a "ONE_TO_MANY" relation
                        // In this case just save the "id" of the remote as field value)
                    case "MANY_TO_ONE":
                        field.type = String;
                        field.dbName = field.dbName + "_ID";
                        properties.push(field);
                        break;
                        // In this case we have to use a mapping table.
                    case "MANY_TO_MANY":
                        break;
                    default:
                        throw new Error("Unsupported relation type '" + relationType + "'");
                }
            }
            // This is a normal property.
            else {
                properties.push(field);
            }
        }
        return properties;
    }

}
}
