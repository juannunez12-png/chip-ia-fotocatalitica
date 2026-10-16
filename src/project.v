
/*
 * Proyecto: Red Neuronal Fotocatalitica Multi-Sensor
 * Plataforma: Tiny Tapeout - SkyWater 130 nm
 * Descripcion: Control inteligente de purificacion de agua
 */

`default_nettype none

module tt_um_red_fotocatalitica (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // =========================================
    // 1. ENTRADAS DE LOS TRES SENSORES
    // =========================================

    // Metales pesados: 4 bits (0 a 15)
    wire [3:0] sensor_metal = ui_in[3:0];

    // Radiacion UV: 2 bits (0 a 3)
    wire [1:0] sensor_uv = ui_in[5:4];

    // Nivel codificado de pH: 2 bits (0 a 3)
    wire [1:0] sensor_ph = ui_in[7:6];


    // =========================================
    // 2. PARAMETROS DE LA NEURONA ARTIFICIAL
    // =========================================

    localparam signed [7:0] PESO_METAL = 8'sd8;
    localparam signed [7:0] PESO_UV = -8'sd12;
    localparam signed [7:0] PESO_PH = 8'sd4;

    localparam signed [7:0] SESGO = 8'sd20;

    localparam signed [15:0] UMBRAL = 16'sd40;


    // =========================================
    // 3. OPERACIONES MATEMATICAS
    // =========================================

    // Multiplicacion de metales pesados
    wire signed [15:0] mult_metal =
        $signed({12'b0, sensor_metal}) * PESO_METAL;

    // Multiplicacion de radiacion UV
    wire signed [15:0] mult_uv =
        $signed({14'b0, sensor_uv}) * PESO_UV;

    // Multiplicacion de pH
    wire signed [15:0] mult_ph =
        $signed({14'b0, sensor_ph}) * PESO_PH;

    // Calculo del riesgo total
    wire signed [15:0] suma_total =
        mult_metal + mult_uv + mult_ph + SESGO;


    // =========================================
    // 4. DETECCION DE AUSENCIA DE LUZ UV
    // =========================================

    wire alarma_uv = (sensor_uv == 2'b00);


    // =========================================
    // 5. CONTROL DE LA VALVULA
    // =========================================

    reg valvula_abierta;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            valvula_abierta <= 1'b0;

        else if (alarma_uv || (suma_total > UMBRAL))
            valvula_abierta <= 1'b0;

        else
            valvula_abierta <= 1'b1;

    end


    // =========================================
    // 6. SALIDAS DEL CHIP
    // =========================================

    // Bit 0: Valvula de salida
    // Bit 1: Alarma de ausencia de UV
    assign uo_out = {
        6'b000000,
        alarma_uv,
        valvula_abierta
    };


    // =========================================
    // 7. PINES BIDIRECCIONALES SIN USAR
    // =========================================

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Entrada ena y bus uio_in no utilizados
    wire _unused = &{ena, uio_in, 1'b0};

endmodule

`default_nettype wire
