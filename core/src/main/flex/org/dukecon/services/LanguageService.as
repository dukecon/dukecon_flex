/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.model.Language;

public class LanguageService {

    private var em:EntityManager;

    public function LanguageService() {
        em = EntityManager.instance;
    }

    public function get languages():ArrayCollection {
        return em.findAll(Language);
    }

}
}
