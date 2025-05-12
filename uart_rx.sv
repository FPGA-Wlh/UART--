`timescale 1ns / 1ps
module uart_rx(
    input  logic       clk_i       ,
    input  logic       rst_n       ,
    input  logic       uart_rxdata ,
    output logic       uart_rx_done,
    output logic [7:0] uart_rx_data
          
    );
    
    parameter  CLK_FREQ = 100_000_000; // Clock Frequency
    parameter  UART_BPS = 115200; // Baud Rate
    localparam BAUD_CNT_MAX = CLK_FREQ/UART_BPS; //Maximum Baud Rate Count
        
    logic        reg_uart_rxdata_0;  
    logic        reg_uart_rxdata_1;
    logic        reg_uart_rxdata_2;
    logic        start_en; // 开始接收
    logic        rx_flag; // 
    
    logic [7:0]  reg_uart_rx_data; // 接收数据缓存
    logic [15:0] baud_cnt; // 时钟计数
    logic [3:0]  rx_cnt; // 波特率计数
    
    assign start_en = reg_uart_rxdata_2 & (~reg_uart_rxdata_1);
    // 接收数据信号消抖延时
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            reg_uart_rxdata_0 <= 1'b0;
            reg_uart_rxdata_1 <= 1'b0;
            reg_uart_rxdata_2 <= 1'b0;
        end else begin
            reg_uart_rxdata_0 <= uart_rxdata;
            reg_uart_rxdata_1 <= reg_uart_rxdata_0;
            reg_uart_rxdata_2 <= reg_uart_rxdata_1;
        end 
    end
    
    // 接收数据信号标志
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            rx_flag <= 1'b0;
        end else if(start_en) begin
            rx_flag <= 1'b1;
        end else if(rx_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX/2 - 1)begin
            rx_flag <= 1'b0;
        end else begin
            rx_flag <= rx_flag;
        end
    end
    
    // 波特率计数
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            baud_cnt <= 16'd0;
        end else if(rx_flag) begin
            if(baud_cnt < BAUD_CNT_MAX -1) begin
                baud_cnt <= baud_cnt + 1'b1;
            end else begin
                baud_cnt <= 16'd0;
            end   
        end else begin
            baud_cnt <= 16'd0;
        end
    end
    
    // 数据计数
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            rx_cnt <= 4'd0;
        end else if(rx_flag) begin
            if(baud_cnt == BAUD_CNT_MAX -1) begin
                rx_cnt <= rx_cnt + 1'b1;
            end else begin
                rx_cnt <= rx_cnt;
            end   
        end else begin
            rx_cnt <= 4'd0;
        end
    end
    
    // 接收数据到缓存
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            reg_uart_rx_data <= 8'b0;
        end else if(rx_flag) begin
            if(baud_cnt == BAUD_CNT_MAX/2 -1'b1) begin
                case(rx_cnt) 
                    4'd1: reg_uart_rx_data[0] <= reg_uart_rxdata_2;
                    4'd2: reg_uart_rx_data[1] <= reg_uart_rxdata_2;
                    4'd3: reg_uart_rx_data[2] <= reg_uart_rxdata_2;
                    4'd4: reg_uart_rx_data[3] <= reg_uart_rxdata_2;
                    4'd5: reg_uart_rx_data[4] <= reg_uart_rxdata_2;
                    4'd6: reg_uart_rx_data[5] <= reg_uart_rxdata_2;
                    4'd7: reg_uart_rx_data[6] <= reg_uart_rxdata_2;
                    4'd8: reg_uart_rx_data[7] <= reg_uart_rxdata_2;
                   // 4'd9: uart_rx_data <= reg_uart_rxdata_2;
                    default: ;
                endcase
            end else begin
                reg_uart_rx_data <= reg_uart_rx_data;
            end 
        end else begin
            reg_uart_rx_data <= 8'b0;
        end
    end
    
    always@(posedge clk_i or negedge rst_n) begin
        if(!rst_n) begin
            uart_rx_done <= 1'b0;
            uart_rx_data <= 8'b0;
        end else if((rx_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX/2 -1'b1)) begin
            uart_rx_done <= 1'b1;
            uart_rx_data <= reg_uart_rx_data;
        end else begin
            uart_rx_done <= 1'b0;
            uart_rx_data <= uart_rx_data;
        end
    end
    
    
    
endmodule


