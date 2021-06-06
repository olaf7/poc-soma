graph LR
    A[Soma Smart Shades App] --> |WiFI| B[Soma Connect]
    B --> |BLE| C[Soma Tilt or Shades]
        
    D[Home Assistant App] --> |WiFi| E[Home Assistant]
    E --> F[Soma HA Integration]
    F --> B

    G[Python script : soma.sh] -->|Soma REST API| B

    H[Python script : soma-ha.sh] -->|HA REST API| E
