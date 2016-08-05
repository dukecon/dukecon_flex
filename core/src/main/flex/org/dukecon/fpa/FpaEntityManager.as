/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.fpa {
import flash.utils.Dictionary;

import org.dukecon.model.Identifyable;

public class FpaEntityManager {

    private var typeMappings:Dictionary;

    public function FpaEntityManager() {
        typeMappings = new Dictionary();
    }

    public function registerType(type:Class):void {
        // Create a new instance of a mapper.
        var mapper:FpaTypeMapper = new FpaTypeMapper(type);
        try {
            // Check if the table for this mapping exists.
            if(mappingExists(mapper)) {
                // Check if the mapping is valid.
                if(!mappingCheck(mapper)) {
                    // If it was not valid, delete the old structures and create new ones
                    // TODO: Find a way to somehow gracefully allow migrations ...
                    mappingDelete(mapper);
                    mappingCreate(mapper);
                }
            } else {
                // Define the needed data structures in the database.
                mappingCreate(mapper);
            }

            // Add the mapper to the mapper map
            typeMappings[type] = mapper;
        } catch(e:Error) {
            // TODO: Handle this ...
        }
    }

    public function persist(obj:Identifyable):void {

    }

    public function remove(obj:Identifyable):void {

    }

    public function get(type:Class, id:Number):Object {
        return null;
    }

    public function list(type:Class):Array {
        return null;
    }

    /**
     * Checks if the databse structures backing this type have been created.
     * @param mapper Mapper instance we want to check
     * @return true if the structures are generally available (not doing a validity check)
     */
    private function mappingExists(mapper:FpaTypeMapper):Boolean {
        return false;
    }

    /**
     * A mapping is tightly coupled with the database table it belongs to.
     * If the type changed it will no longer fit to the database table. In
     * this function we will check if this mapping conflicts with the
     * structure in the database.
     * @param mapper Mapper instance we want to validate
     * @return true if the mapping is valid, false if it doesn't fit
     */
    private function mappingCheck(mapper:FpaTypeMapper):Boolean {
        return false;
    }

    /**
     * Create the data structures needed to persist the given mapper type.
     * @param mapper Mapper instance the data structures should be created for
     * @return true if the creation of data structures was successful
     */
    private function mappingCreate(mapper:FpaTypeMapper):Boolean {
        return false;
    }

    /**
     * Delete the datastructures for a given type. This is usually needed
     * if the persisted types have changed.
     * @param mapper Mapper instance the data structures should be deleted for
     * @return true if the deletion of data structures was successful
     */
    private function mappingDelete(mapper:FpaTypeMapper):Boolean {
        return false;
    }

    private function getTableName(mapper:FpaTypeMapper):String {
        return null;
    }

}
}
