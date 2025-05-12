`timescale 1ns / 1ps
module uart_top(
    input  logic        sys_clk_p    ,
    input  logic        sys_clk_n    ,
    input  logic        sys_rst_n    ,
    input  logic        uart_rx      ,
    output logic        uart_tx      
    );
    parameter  CLK_FREQ = 100_000_000; // Clock Frequency
    parameter  UART_BPS = 115200; // Baud Rate
    
    logic         sys_clk     ;
    logic         uart_rx_done;
    logic  [7:0]  uart_rx_data;
    logic         uart_tx_en;
    logic  [7:0]  uart_tx_data;
    logic         uart_tx_busy;
    
    IBUFDS diff_clock(
            .I (sys_clk_p), 
            .IB(sys_clk_n), 
            .O (sys_clk)    
        );
        
    ila_0 u_ila_0 (
	.clk(sys_clk), // input wire clk


	.probe0(sys_clk), // input wire [0:0]  probe0  
	.probe1(uart_rx), // input wire [0:0]  probe1 
	.probe2(uart_tx), // input wire [0:0]  probe2 
	.probe3(uart_tx_en), // input wire [0:0]  probe3 
	.probe4(uart_rx_data), // input wire [0:0]  probe4 
	.probe5(uart_tx_data), // input wire [0:0]  probe5 
	.probe6(uart_rx_done) // input wire [0:0]  probe6
);


    
    uart_rx #(
        .CLK_FREQ      (CLK_FREQ      ),    
        .UART_BPS      (UART_BPS      )
    )u_uart_rx(
        .clk_i         (sys_clk       ),
        .rst_n         (sys_rst_n     ),
        .uart_rxdata   (uart_rx       ),
        .uart_rx_done  (uart_rx_done  ),
        .uart_rx_data  (uart_rx_data  ) 
    );
    
    
    uart_tx #(
        .CLK_FREQ      (CLK_FREQ      ),    
        .UART_BPS      (UART_BPS      )
    )u_uart_tx(
        .clk_i         (sys_clk       ),
        .rst_n         (sys_rst_n     ),
        .uart_tx_en    (uart_rx_done  ),
        .uart_tx_data  (uart_rx_data  ),
        .uart_txdata   (uart_tx       ),
        .uart_tx_busy  (              ) 
    );
    
    
    
    
    
    
endmodule


