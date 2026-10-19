package com.mapfre.pgm.bff.infrastructure.observability;

import ch.qos.logback.classic.spi.ILoggingEvent;
import com.fasterxml.jackson.core.JsonGenerator;
import java.io.IOException;
import net.logstash.logback.composite.AbstractFieldJsonProvider;
import net.logstash.logback.composite.FieldNamesAware;
import net.logstash.logback.fieldnames.LogstashFieldNames;

/** Proveedor del campo "message" con enmascarado de PII (ARQT-SBOOT-001: logs JSON sin datos personales). */
public class PiiMaskingMessageJsonProvider extends AbstractFieldJsonProvider<ILoggingEvent>
        implements FieldNamesAware<LogstashFieldNames> {

    public PiiMaskingMessageJsonProvider() {
        setFieldName("message");
    }

    @Override
    public void writeTo(JsonGenerator generator, ILoggingEvent event) throws IOException {
        generator.writeStringField(getFieldName(), PiiMasker.mask(event.getFormattedMessage()));
    }

    @Override
    public void setFieldNames(LogstashFieldNames fieldNames) {
        setFieldName(fieldNames.getMessage());
    }
}
