package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import com.mapfre.vida.vencimientosmanuales.infrastructure.observability.PiiMasker;

@Aspect
@Component
public class HostAuditAspect {
    private static final Logger AUDIT = LoggerFactory.getLogger("host.audit");

    @Around("@annotation(com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host.HostAudit)")
    public Object audit(ProceedingJoinPoint call) throws Throwable {
        long start = System.nanoTime();
        String operation = call.getArgs().length == 0 ? "unknown" : String.valueOf(call.getArgs()[0]);
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String user = authentication == null || authentication.getName() == null
                ? "local" : PiiMasker.mask(authentication.getName());
        try {
            Object result = call.proceed();
            AUDIT.info("host_call operation={} user={} result=success duration_ms={}",
                    operation, user, (System.nanoTime() - start) / 1_000_000);
            return result;
        } catch (Throwable failure) {
            AUDIT.info("host_call operation={} user={} result=failure duration_ms={}",
                    operation, user, (System.nanoTime() - start) / 1_000_000);
            throw failure;
        }
    }
}
