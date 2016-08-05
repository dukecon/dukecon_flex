package org.dukecon.utils.generator;

import org.granite.generator.Listener;
import org.granite.generator.as3.JavaAs3GroovyConfiguration;
import org.granite.generator.as3.JavaAs3GroovyTransformer;
import org.granite.generator.as3.JavaAs3Input;
import org.granite.generator.as3.JavaAs3Output;
import org.granite.generator.exception.TemplateUriException;
import org.granite.generator.gsp.GroovyTemplate;

import java.io.IOException;

/**
 * Created by christoferdutz on 04.08.16.
 */
public class FlexORMTransformer extends JavaAs3GroovyTransformer {

    public FlexORMTransformer() {
    }

    public FlexORMTransformer(JavaAs3GroovyConfiguration config, Listener listener) {
        super(config, listener);
    }

    @Override
    protected String getOutputFileSuffix(JavaAs3Input input, GroovyTemplate template) {
        return template.isBase()?"":"Helper";
    }

    @Override
    protected JavaAs3Output[] getOutputs(JavaAs3Input input) throws IOException, TemplateUriException {
        return super.getOutputs(input);
    }

}
