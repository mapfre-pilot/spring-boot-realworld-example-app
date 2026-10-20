package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.exception.DemasiadosResultadosException;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.exception.SistemaExternoException;
import io.github.resilience4j.circuitbreaker.CallNotPermittedException;
import com.mapfre.pgm.bff.infrastructure.observability.PiiMasker;
import java.net.URI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

/** Errores en formato RFC 9457 (application/problem+json), tal como exige BP-API-001. Nunca se devuelve PII ni trazas. */
@RestControllerAdvice
public class ApiExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);
    private static final String TIPO_BASE = "https://pgm.mapfre.es/problems/";

    @ExceptionHandler(DemasiadosResultadosException.class)
    ProblemDetail demasiadosResultados(DemasiadosResultadosException e) {
        return problem(HttpStatus.UNPROCESSABLE_ENTITY, "demasiados-resultados", "Hay demasiados resultados para los criterios introducidos", e.getMessage());
    }

    @ExceptionHandler(RecursoNoEncontradoException.class)
    ProblemDetail noEncontrado(RecursoNoEncontradoException e) {
        return problem(HttpStatus.NOT_FOUND, "recurso-no-encontrado", "Recurso no encontrado", e.getMessage());
    }

    @ExceptionHandler(NoResourceFoundException.class)
    ProblemDetail rutaInexistente(NoResourceFoundException e) {
        return problem(HttpStatus.NOT_FOUND, "ruta-inexistente", "Ruta no encontrada", "No existe el recurso solicitado");
    }

    @ExceptionHandler(AccesoNoAutorizadoException.class)
    ProblemDetail prohibido(AccesoNoAutorizadoException e) {
        return problem(HttpStatus.FORBIDDEN, "acceso-no-autorizado", "Acceso no autorizado", e.getMessage());
    }

    @ExceptionHandler({IllegalArgumentException.class, MissingServletRequestParameterException.class,
            MethodArgumentTypeMismatchException.class})
    ProblemDetail peticionInvalida(Exception e) {
        return problem(HttpStatus.BAD_REQUEST, "peticion-invalida", "Petición inválida", PiiMasker.mask(e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ProblemDetail validacion(MethodArgumentNotValidException e) {
        String detalle = e.getBindingResult().getFieldErrors().stream()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .reduce((a, b) -> a + "; " + b).orElse("Datos inválidos");
        ProblemDetail pd = problem(HttpStatus.BAD_REQUEST, "validacion", "Datos inválidos", detalle);
        pd.setProperty("campos", e.getBindingResult().getFieldErrors().stream().map(FieldError::getField).toList());
        return pd;
    }

    @ExceptionHandler(SistemaExternoException.class)
    ProblemDetail externo(SistemaExternoException e) {
        log.warn("Fallo de sistema externo sistema={} causa={}", e.getSistema(), e.getClass().getSimpleName());
        ProblemDetail pd = problem(HttpStatus.BAD_GATEWAY, "sistema-externo", "Servicio no disponible temporalmente",
                "No se pudo completar la operación con " + e.getSistema() + ". Inténtelo de nuevo.");
        pd.setProperty("sistema", e.getSistema());
        return pd;
    }

    @ExceptionHandler(IdempotenciaEnConflictoException.class)
    ProblemDetail idempotenciaEnConflicto(IdempotenciaEnConflictoException e) {
        return problem(HttpStatus.CONFLICT, "idempotencia-en-conflicto", "Clave de idempotencia en conflicto", e.getMessage());
    }

    @ExceptionHandler(CallNotPermittedException.class)
    ProblemDetail circuitoAbierto(CallNotPermittedException e) {
        return problem(HttpStatus.SERVICE_UNAVAILABLE, "sistema-externo", "Servicio no disponible temporalmente",
                "El circuito del servicio externo está abierto. Inténtelo de nuevo más tarde.");
    }

    @ExceptionHandler(Exception.class)
    ProblemDetail interno(Exception e) {
        log.error("Error no controlado tipo={}", e.getClass().getName(), e);
        return problem(HttpStatus.INTERNAL_SERVER_ERROR, "error-interno", "Error interno", "Se ha producido un error inesperado");
    }

    private static ProblemDetail problem(HttpStatus status, String tipo, String titulo, String detalle) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(status, detalle);
        pd.setType(URI.create(TIPO_BASE + tipo));
        pd.setTitle(titulo);
        return pd;
    }
}
