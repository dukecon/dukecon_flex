<%

    Set as3Imports = new TreeSet();

    for (jImport in jClass.imports) {
        if (jImport.as3Type.hasPackage()) {
            // BlazeDS uses ArrayCollections instead of ListCollectionVies
            if(jImport.as3Type.qualifiedName == "mx.collections.ListCollectionView") {
            }
            // BlazeDS uses Object instead of IMap for communicating Maps.
            // As Object needs no import, simply omit the import.
            else if(jImport.as3Type.qualifiedName == "org.granite.collections.IMap") {
            }
            // We will use Date for this type and that needs no import.
            else if(jImport.as3Type.qualifiedName == "java.time.LocalDateTime") {
            }
            // We don't need imports of the same package.
            else {
                if(jImport.as3Type.packageName != jClass.as3Type.packageName) {
                    as3Imports.add(jImport.as3Type.qualifiedName);
                }
            }
        }
    }

%>/**
 * Generated by Gas3 v${gVersion} (Granite Data Services).
 *
 * WARNING: DO NOT CHANGE THIS FILE. IT MAY BE OVERRIDDEN EACH TIME YOU USE
 * THE GENERATOR. CHANGE INSTEAD THE INHERITED CLASS (${jClass.as3Type.name}.as).
 */

package ${jClass.as3Type.packageName} {

import mx.collections.ArrayCollection;

import org.dukecon.model.LocalDateTime;

<%
///////////////////////////////////////////////////////////////////////////////
// Write Import Statements.

    for (as3Import in as3Imports) {%>
import ${as3Import};<%
    }

///////////////////////////////////////////////////////////////////////////////
// Write Class Declaration.%>

[Bindable]
[RemoteClass(alias="${jClass.qualifiedName}")]
public class ${jClass.as3Type.name}<%

        if (jClass.hasSuperclass()) {
            %> extends ${jClass.superclass.as3Type.name}<%
        }

        boolean implementsWritten = false;
        for (jInterface in jClass.interfaces) {
            if (!implementsWritten) {
                %> implements ${jInterface.as3Type.name}<%

                implementsWritten = true;
            } else {
                %>, ${jInterface.as3Type.name}<%
            }
        }
    %> {
<%

    ///////////////////////////////////////////////////////////////////////////
    // Write Private Fields.

    for (jProperty in jClass.properties) {
        if(jProperty.as3Type.name == "ListCollectionView") { %>
    private var _${jProperty.name}:ArrayCollection;<%
        } else if(jProperty.as3Type.name == "IMap") { %>
    private var _${jProperty.name}:Object;<%
        } else { %>
    private var _${jProperty.name}:${jProperty.as3Type.name};<%
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write constructor
%>

    public function ${jClass.as3Type.name}() {
    }<%

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getter/Setter.

    for (jProperty in jClass.properties) {
        if (jProperty.readable) { %>
        <%
            // TODO: We should check if the class implements Identifyable ...
            if(jProperty.name == "id") { %>
    [Id(strategy='assigned')]<%
            }
            // "order" is a reserved word ...
            if(jProperty.name == "order") { %>
    [Column(name='ord')]<%
            }
            // If the property was annotated with "Relation", add some metadata to the getter
            if(jProperty.isAnnotationPresent(org.dukecon.model.annotations.Relation)) {
                if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).relationType() == org.dukecon.model.annotations.Relation.RelationType.ONE_TO_ONE) { %>
    [ManyToOne]<%
                } else if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).relationType() == org.dukecon.model.annotations.Relation.RelationType.ONE_TO_MANY && jClass.as3Type.name == "Conference") {
                    if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).remoteType() != null) { %>
    [OneToMany(type='${jProperty.getAnnotation(org.dukecon.model.annotations.Relation).remoteType().getCanonicalName()}', fkColumn='conference_id', constrain='false')]<%
                    } else if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).remoteType() != null) { %>
    [OneToMany(type='${jProperty.getAnnotation(org.dukecon.model.annotations.Relation).remoteType().getCanonicalName()}')]<%
                    } else { %>
    [OneToMany]<%
                    }
                } else if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).relationType() == org.dukecon.model.annotations.Relation.RelationType.MANY_TO_ONE && jProperty.name == 'conference') { %>
    [ManyToOne(inverse='true')]<%
                } else if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).relationType() == org.dukecon.model.annotations.Relation.RelationType.MANY_TO_ONE) { %>
    [ManyToOne]<%
                } else if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).relationType() == org.dukecon.model.annotations.Relation.RelationType.MANY_TO_MANY) {
                    if(jProperty.getAnnotation(org.dukecon.model.annotations.Relation).remoteType() != null) { %>
    [ManyToMany(type='${jProperty.getAnnotation(org.dukecon.model.annotations.Relation).remoteType().getCanonicalName()}')]<%
                    } else { %>
    [ManyToMany]<%
                    }
                }
            }
            if(jProperty.as3Type.name == "LocalDateTime" || jProperty.as3Type.name == "MetaData" || jProperty.name == "names") { %>
    [Transient]<%
            }
            if(jProperty.as3Type.name == "ListCollectionView") { %>
    public function get ${jProperty.name}():ArrayCollection {
        return _${jProperty.name};
    }<%
            } else if(jProperty.as3Type.name == "IMap") { %>
    public function get ${jProperty.name}():Object {
        return _${jProperty.name};
    }<%
            } else { %>
    public function get ${jProperty.name}():${jProperty.as3Type.name} {
        return _${jProperty.name};
    }<%
            }
        }
        if (jProperty.writable) {
            if(jProperty.as3Type.name == "ListCollectionView") { %>
    public function set ${jProperty.name}(value:ArrayCollection):void {
        _${jProperty.name} = value;
    }<%
            } else if(jProperty.as3Type.name == "IMap") { %>
    public function set ${jProperty.name}(value:Object):void {
        _${jProperty.name} = value;
    }<%
            } else { %>
    public function set ${jProperty.name}(value:${jProperty.as3Type.name}):void {
        _${jProperty.name} = value;
    }<%
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getters/Setters for Implemented Interfaces.

    if (jClass.hasInterfaces()) {
        for (jProperty in jClass.interfacesProperties) {
            if (jProperty.readable || jProperty.writable) {%>
<%
                if (jProperty.writable) {%>
    public function set ${jProperty.name}(value:${jProperty.as3Type.name}):void {
    }<%
                }
                if (jProperty.readable) {%>
    public function get ${jProperty.name}():${jProperty.as3Type.name} {
        return ${jProperty.as3Type.nullValue};
    }<%
                }
            }
        }
    }%>

}
}