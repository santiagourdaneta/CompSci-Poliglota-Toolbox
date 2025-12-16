import http from 'k6/http';
import { check, sleep } from 'k6';

// -----------------------------------------------------------
// 1. Configuración de la prueba de Estrés
// -----------------------------------------------------------
export const options = {
    // Definimos el escenario principal
    stages: [
        // 1. Fase de rampa (subir la carga)
        // Subir de 0 a 100 usuarios en 30 segundos
        { duration: '30s', target: 100 }, 
        // 2. Fase de carga (mantener el estrés)
        // Mantener 100 usuarios concurrentes durante 30 segundos
        { duration: '30s', target: 100 }, 
        // 3. Fase de rampa abajo (terminar la prueba)
        // Bajar de 100 a 0 usuarios en 5 segundos
        { duration: '5s', target: 0 }, 
    ],
    // Indicarle a k6 que los códigos 503 NO son fallos de red.
    ext: {
            loadimpact: {
                // Códigos de respuesta HTTP que NO deben contarse en http_req_failed
                responseStatuses: {
                    '200': 'ok',
                    '503': 'rate_limited', 
                },
            },
        },
        // Definimos los umbrales de éxito (Service Level Objectives - SLOs)
        thresholds: {
            // Umbral de tasa de fallo bajo
            http_req_failed: ['rate < 0.10'], // Solo los fallos 500/4xx cuentan.
            http_req_duration: ['p(95) < 2000'],
        },
    };

// -----------------------------------------------------------
// 2. Flujo de prueba (La función ejecutada por cada usuario virtual)
// -----------------------------------------------------------
export default function () {
    // URL del orquestador Ruby (Web Server)
    const url = 'http://localhost:9292/';

    // Petición GET a la página principal
    const res = http.get(url);
    
    // Que la prueba cuente 200 y 503 como "correctos".
        check(res, {
            'Status 200 (Success)': (r) => r.status === 200,
            'Status 503 (Rate Limited)': (r) => r.status === 503,
        });
        
        // Solo verificar el contenido si la petición fue 200
        if (res.status === 200) {
            check(res, {
                'Contiene resultado de Go': (r) => r.body.includes('Hash calculado en Go'),
            });
        }

    // Esperar un momento (1 segundo) para simular el tiempo que pasa un usuario real
    sleep(1); 
}