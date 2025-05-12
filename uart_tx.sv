`timescale 1ns / 1ps
module uart_tx(
    input  logic        clk_i        ,
    input  logic        rst_n        ,
    input  logic        uart_tx_en   ,
    input  logic [7:0]  uart_tx_data ,
    output logic        uart_txdata  ,
    output logic        uart_tx_busy
    );
    
    parameter  CLK_FREQ = 100_000_000; // Clock Frequency
    parameter  UART_BPS = 115200; // Baud Rate
    localparam BAUD_CNT_MAX = CLK_FREQ/UART_BPS; //Maximum Baud Rate Count
    
    logic  [7:0]  reg_tx_data; // Data Buffer
    logic  [3:0]  tx_cnt; // Send data count
    logic  [15:0] baud_cnt; // 
    
    // 
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            reg_tx_data <= 8'b0;
            uart_tx_busy <= 1'b0;
        end else if(uart_tx_en) begin
            reg_tx_data <= uart_tx_data;
            uart_tx_busy <= 1'b1;
        end else if(tx_cnt == 4'd9 && baud_cnt == (BAUD_CNT_MAX - BAUD_CNT_MAX/16)) begin
            reg_tx_data <= 8'b0;
            uart_tx_busy <= 1'b0;
        end else begin
            reg_tx_data <= reg_tx_data;
            uart_tx_busy <= uart_tx_busy;
        end
    end
    
    // baud_cnt
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            baud_cnt <= 16'd0;
        end else if(uart_tx_en) begin
            baud_cnt <= 16'b0;
        end else if(uart_tx_busy) begin
            if(baud_cnt < BAUD_CNT_MAX-1'b1) begin
                baud_cnt <= baud_cnt + 1'b1;
            end else begin
                baud_cnt <= 16'd0;
            end
        end else begin
            baud_cnt <= 16'd0;
        end
    end
    
    // tx_cnt 赋值
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            tx_cnt <= 4'd0;
        end else if(uart_tx_en) begin
            tx_cnt <= 4'd0;
        end else if(uart_tx_busy) begin
            if(baud_cnt == BAUD_CNT_MAX-1'b1) begin
                tx_cnt <= tx_cnt + 1'b1;
            end else begin
                tx_cnt <= tx_cnt;
            end
        end else begin
            tx_cnt <= 4'd0;
        end
    end
    
    // uart_txdata
    always_ff@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            uart_txdata <= 4'd0;
        end else if(uart_tx_busy) begin
            case(tx_cnt)
                4'd0: uart_txdata <= 1'b0;
                4'd1: uart_txdata <= reg_tx_data[0];
                4'd2: uart_txdata <= reg_tx_data[1];
                4'd3: uart_txdata <= reg_tx_data[2];
                4'd4: uart_txdata <= reg_tx_data[3];
                4'd5: uart_txdata <= reg_tx_data[4];
                4'd6: uart_txdata <= reg_tx_data[5];
                4'd7: uart_txdata <= reg_tx_data[6];
                4'd8: uart_txdata <= reg_tx_data[7];
                4'd9: uart_txdata <= 1'b1;
            default: uart_txdata <= 1'b1;
            endcase     
        end else begin
            uart_txdata <= 1'b1;
        end
    end
    
    
    
    
    
    
    
    
endmodule
