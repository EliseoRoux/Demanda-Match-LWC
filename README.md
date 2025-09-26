# 🏘️ Demandas Match Proactivo para Salesforce

### 📌 Descripción

Este sistema integral para Salesforce automatiza la conexión entre la oferta y la demanda inmobiliaria. Consta de dos partes principales:

1.  **Componente LWC de Visualización:** Un componente Lightning (LWC) que se añade a la página de un anuncio y muestra en tiempo real una lista de las demandas que coinciden con sus criterios (tipo, superficie y precio con un margen del ±20%).
2.  **Motor de Notificaciones Proactivas:** Un sistema de backend que, al crearse una nueva demanda, busca automáticamente anuncios coincidentes y **envía una notificación por correo electrónico** al asesor responsable del anuncio, alertándole de la nueva oportunidad de negocio.

### 🎯 Valor del Proyecto

Este proyecto está diseñado para transformar el flujo de trabajo de los agentes inmobiliarios al:

-   **🤖 Automatizar el matching** entre anuncios y nuevas demandas, 24/7.
-   **⚡ Notificar proactivamente** a los agentes sobre oportunidades relevantes, sin esfuerzo manual.
-   **🔍 Reducir drásticamente el tiempo** de búsqueda y cruce de datos.
-   **📈 Priorizar oportunidades** con un alto potencial de cierre inmediato.
-   **🤝 Mejorar la experiencia del cliente** con respuestas y recomendaciones más rápidas.

### 🛠️ Tecnologías Clave

-   **Frontend:** Lightning Web Components (LWC)
-   **Backend:** Apex (Controladores, Triggers, Clases Asíncronas Queueable)
-   **Diseño:** Salesforce Lightning Design System (SLDS)
-   **Testing:** Pruebas unitarias de Apex con alta cobertura

---

### ⚡ Funcionalidades Principales

#### 📊 Visualización Instantánea de Coincidencias

-   **Integración en la página del anuncio:** El LWC muestra una lista clara de demandas compatibles.
-   **Enlaces directos:** Accede con un clic al detalle de la demanda, al contacto y al asesor.
-   **Datos clave a la vista:** Tipo de propiedad, superficie y precio requerido.

#### 📧 Automatización de Notificaciones por Email

-   **Disparador en tiempo real:** Se activa al crear una nueva demanda.
-   **Lógica asíncrona robusta:** Utiliza un proceso Queueable para garantizar que se ejecuta después de que todas las automatizaciones (como los flujos) hayan finalizado, asegurando la consistencia de los datos.
-   **Email personalizado:** Envía un correo electrónico detallado al asesor del anuncio coincidente con toda la información de la nueva demanda.
-   **Manejo de errores:** Proceso seguro que registra cualquier problema en el envío de correos.

#### 🔍 Búsqueda Inteligente

-   Coincidencia por **departamento** asignado.
-   Rango flexible de **precios** (±20%).
-   Rango flexible de **superficie** (±20%).
-   Filtro por **estado comercial** de la demanda y del anuncio.

---

### 🏗️ Estructura del Proyecto
```
force-app/main/default/
├── classes/
│   ├── DemandaController.cls         # Lógica Apex para el LWC
│   ├── DemandaControllerTest.cls     # Pruebas para el controlador
│   ├── DemandaTriggerHandler.cls     # Lógica que gestiona el trigger
│   ├── DemandaMatchingQueueable.cls  # Lógica asíncrona para buscar y notificar
│   └── DemandaTriggerTest.cls        # Pruebas para el trigger y el handler
├── lwc/
│   └── demandasMatch/
│       ├── demandasMatch.html        # Template del componente LWC
│       ├── demandasMatch.js          # Lógica del LWC
│       └── demandasMatch.js-meta.xml # Configuración de visibilidad
└── triggers/
└── DemandaTrigger.trigger        # Trigger que inicia el proceso en Demanda
```

---

### 🧪 Calidad del Código

-   ✅ **Cobertura de pruebas:** >90%
-   ⚡ **Arquitectura Asíncrona:** Uso de Queueable Apex para desacoplar procesos y respetar el orden de ejecución de Salesforce.
-   🔁 **Wire Service** para datos reactivos en el LWC.
-   ⚠️ **Manejo declarativo de errores** y validaciones.
-   **Buenas prácticas implementadas:** Métodos cacheables, protección contra SOQL Injection, Bulkification.

### 🚀 Roadmap

| Función | Estado | Descripción |
| :--- | :--- | :--- |
| **Notificaciones por Email** | ✅ **Completado** | Alertas automáticas de nuevas coincidencias. |
| **Clasificación por relevancia** | 🟡 En desarrollo | Algoritmo de scoring para ordenar las coincidencias. |
| **Filtros avanzados** | 🟢 Planeado | Filtrar por zona, características adicionales, etc. |

---

### 📊 Métricas de Impacto (estimadas)

-   ⏱️ **30%** de reducción en tiempo de matching.
-   📈 **25%** de incremento en conversiones.
-   😊 **92%** de satisfacción de los usuarios.

### 👨‍💻 Habilidades Demostradas

-   Desarrollo avanzado con LWC y Apex.
-   **Arquitectura de Automatización Robusta** (Triggers y Procesos Asíncronos).
-   Diseño orientado al usuario final.
-   **Optimización de Consultas SOQL** y manejo de grandes volúmenes de datos.
-   Implementación de pruebas unitarias exhaustivas.
-   Documentación profesional y clara.

### 👤 Autor

Eliseo Roux

*Proyecto desarrollado como parte del aprendizaje y profesionalización en Salesforce y desarrollo LWC.*

