class uart_monitor;

    // ===================== INSTANTIATION ===================== //
    virtual uart_intf uart_vif;     // UART virtual interface
    mailbox monitor2scoreboard;    // Mailbox for communication
    event start_monitor;           // Event to start monitoring
    event monitor_done;            // Event to signal monitor completion
    int error_count = 0;           // Error counter

    localparam START_BIT = 1'b0;
    localparam STOP_BIT  = 1'b1;

    // ===================== CONSTRUCTOR ===================== //
    function new(
        virtual uart_intf uart_vif,
        mailbox monitor2scoreboard,
        event start_monitor,
        event monitor_done
    );
        this.uart_vif = uart_vif;
        this.monitor2scoreboard = monitor2scoreboard;
        this.start_monitor = start_monitor;
        this.monitor_done = monitor_done;
        $display("### UART Monitor Initialized at %0t ###", $time);
    endfunction

    // ===================== MAIN TASK ===================== //
    task run_monitor;
        fork
            monitor_tx(); // Monitor transmitter
            monitor_rx(); // Monitor receiver
        join_any
        ->monitor_done; // Trigger completion event when any task completes
    endtask

    // ===================== TX MONITOR ===================== //
    task monitor_tx();
        $display("### Monitoring TX (Transmitter) Started ###");
        forever begin
            // Wait for a start condition
            @(posedge uart_vif.clk);
            if (uart_vif.start && uart_vif.tx_active) begin
                $display("TX Operation Started at time %0t", $time);

                // Capture transmitted data
                bit [7:0] tx_data = uart_vif.tx_data_in;
                wait(uart_vif.done_tx); // Wait for TX completion
                $display("TX Done: Transmitted Data = 0x%h at time %0t", tx_data, $time);

                // Forward transaction to the scoreboard
                monitor2scoreboard.put(tx_data);
            end
        end
    endtask

    // ===================== RX MONITOR ===================== //
    task monitor_rx();
        $display("### Monitoring RX (Receiver) Started ###");
        forever begin
            // Wait for the RX line to go low (start bit detected)
            @(posedge uart_vif.clk);
            if (uart_vif.rx_line == START_BIT) begin
                $display("Start Bit Detected at time %0t", $time);
                bit [7:0] rx_data = 0;

                // Sample each bit of data
                for (int i = 0; i < 8; i++) begin
                    repeat((uart_vif.clk_freq / uart_vif.baud_rate)) @(posedge uart_vif.clk);
                    rx_data[i] = uart_vif.rx_line;
                end

                // Wait for the stop bit
                repeat((uart_vif.clk_freq / uart_vif.baud_rate)) @(posedge uart_vif.clk);
                if (uart_vif.rx_line != STOP_BIT) begin
                    $display("Error: Stop Bit Missing or Corrupt at time %0t", $time);
                    error_count++;
                end else begin
                    $display("RX Done: Received Data = 0x%h at time %0t", rx_data, $time);
                    // Forward received data to the scoreboard
                    monitor2scoreboard.put(rx_data);
                end
            end
        end
    endtask

endclass

