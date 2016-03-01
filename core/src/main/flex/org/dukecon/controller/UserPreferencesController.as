/**
 * Created by christoferdutz on 29.02.16.
 */
package org.dukecon.controller {
import mx.collections.ArrayCollection;

import org.dukecon.model.user.UserPreference;

public interface UserPreferencesController {

    /**
     * Simple list to return a list of user preferences.
     *
     * @return list of all user preferences the current user has.
     */
    function list():ArrayCollection;

    /**
     * Replaces all user preferences with the ones passed to this
     * function.
     *
     * @param userPreferences list of all user preferences.
     */
    function replaceAll(userPreferences:ArrayCollection):void;

    /**
     * Adds a new user preference to the list.
     *
     * @param userPreference user preference instance to add.
     */
    function add(userPreference:UserPreference):void;

    /**
     * Removes a user preference from the list.
     *
     * @param userPreference user preference that should be removed.
     */
    function del(userPreference:UserPreference):void;

}
}
