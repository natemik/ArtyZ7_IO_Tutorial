# Arty Z7 Tutorial
### Reference Manual: https://reference.digilentinc.com/programmable-logic/arty-z7/reference-manual

## Objective
The objective of this tutorial is to introduce you to the Arty Z7 Development Board by constructing and reviewing a basic program made to control some IO devices. Additionally, this tutorial will review design files specific to the Arty Z7 Development Board and ways to expand the constraints to accommodate future designs.

## Setup
This tutorial is done using Xilinx Vivado 2020.1, however similar recent versions should produce the same results. A new project will be made for this tutorial, therefor the provided tutorial code can be considered a model. To begin, open an instance of Vivado and create a new project by selecting 'Create Project' in the Quick Start menu. Following the steps in the wizard, give a name to your project. Next, set the project type to 'RTL Project' if not already done so. There are no current sources or constraints that are known so skip through those prompts. Finally, the part must be selected that we will implement our project onto. The part number for the Arty Z7 with the Zynq Z-7020 processing system is "xc7z020clg400-1". Refer to your development boards documentation if you are unsure what processing system your board has. The wizard can be closed by selecting 'Finish' and the project will then be initialized, this may take a moment. 

## Introduction
The Arty Z7 is a development board centered around the Zynq-7000 SoC (System On Chip). It features a dual-core 650 MHz Cortex-A9 processor equipped with a generous FPGA (Field Programmable Gate Array). The board offers many I/O devices which includes 4 Buttons, 2 Switches, 4 LEDs and 2 RGB LEDs which will all be used in this tutorial. Additional specs and features can be found in the Arty Z7 Reference Manual. In this tutorial, to control these I/O devices we will be writing VHDL code. The press of a button will be designed to turn on an LED, we will create a process to cycle through colors on the RGB LEDs, and the switches will turn those RGB LEDs on and off.

## Design
In this tutorial, only one VHDL source file will be used. To create this file, select the '+' button in the 'Sources' tab. Select 'Add or create design sources', 'Next', and 'Create File'. Name the file as you wish, however try to keep it meaningful (ie. "Tutorial"). Select 'Finish' and leave the module definition default by selecting 'OK'. The file created should now be visible in the 'Design Sources' folder in the 'Sources' tab. Double click that file to open it in Vivado's text editor.

The VHDL model is partitioned into an entity and architecture. The entity describes the external interfaces such as inputs, outputs, and their types. The architecture(s) describes the implementation of the component. The advantage of this design is by defining a single entity, multiple architectures can be defined easily. Additionally, it enables modular design by allowing component architectures to be changed without touching the external connections.

Our design will begin by defining an entity for our tutorial component, but leaving the ports empty to begin.
```vhdl
entity tutorial is
    Port ();
end tutorial;
```
The architecture will be defined now and lets call this architecture the `Behavioural` architecture.
```vhdl
architecture Behavioral of tutorial is
begin
end Behavioral;
```
The basic structure of our VHDL file is now created and we can begin designing the behaviour for the I/O components.

### Buttons and LEDs
The Arty Z7 board features 4 buttons and 4 LEDs. In this design, pressing a button will turn on the LED directly above it. For our component to control these I/O devices, we must create ports in and out of the component for the button and LED signals respectively. To do this, the `entity` declaration now becomes the following.
```vhdl
entity tutorial is
    Port ( 
        -- Defining the 4 buttons as inputs so their logic values can be read
        -- Button pressed is represented by a logic '1'
        -- Button released is represented by a logic '0'
        btn0 : IN   std_logic;
        btn1 : IN   std_logic;
        btn2 : IN   std_logic;
        btn3 : IN   std_logic;
        
        -- Defining the 4 LEDs as outputs so we can write logic values to them
        -- LED ON is represented by driving a logic '1'
        -- LED OFF is represented by driving a logic '0'
        led0 : OUT  std_logic;
        led1 : OUT  std_logic;
        led2 : OUT  std_logic;
        led3 : OUT  std_logic -- Note the absence of a semicolon on the last port declaration. This is VHDL syntax.
    );
end tutorial;
```
These ports are now part of our component as inputs and outputs. The button values must first be read to determine the state of the corresponding LED. Within the architecture, a `process` for each button can be created to read the logic value of the button and drive the desired logic value to the LED. In VHDL a `process` statement includes `sequential` statements that assign values to signals in a "step-by-step" manner. A `process` can contain a sensitivity list, which is a list that defines the signals that control when the process should wake up or execute. Finally, processes are concurrent statements meaning all processes in a design execute concurrently (at the same time). The process for one of the four buttons is shown below. Similar processes are created for the remaining buttons and LEDs.
```vhdl
-- Defining led0 behaviour using "if" conditional statements
btn0_proc : process (btn0) -- When the value of btn0 changes...
begin
    if (btn0 = '1') then -- If the button is pressed
        led0 <= '1'; -- Turn the LED ON
    else
        led0 <= '0'; -- Otherwise turn the LED OFF
    end if;
end process;
```

### Switches and RGB LEDs

Finally, the switches will be used to turn the RGB LEDs on and off. The switches will be taken as inputs and the values of the Red Green and Blue bits will be set as outputs. The completed entity is shown below which includes the declaration of the switch and RGB led ports.
```vhdl
entity tutorial is
    Port ( 
        clk : IN    std_logic;
    
        btn0 : IN   std_logic;
        btn1 : IN   std_logic;
        btn2 : IN   std_logic;
        btn3 : IN   std_logic;
        
        led0 : OUT  std_logic;
        led1 : OUT  std_logic;
        led2 : OUT  std_logic;
        led3 : OUT  std_logic;
        
        sw0 : IN std_logic;
        sw1 : IN std_logic;
        
        -- Default the RGB bits to off 
        led0_RGB : OUT std_logic_vector(2 downto 0) := "000";
        led1_RGB : OUT std_logic_vector(2 downto 0) := "000"
    );
end tutorial;
```
Similar to reading the button state, a process can be created to read the switch state to determine the values of the RGB LEDs. In this tutorial, all possible values of the RGB LED will be displayed. To do this, the bits of the RGB LED output need to first be understood. As seen in the LEDs port declartion, the RGB LED requires three bits, one for each color respectively. For example, the bit vector "100" represents the Red diode being ON, and the Blue and Green diodes being OFF resulting in a Red light. Similarily, the bit vector "011" represents the Red diode being OFF, and the Green and Blue diodes being ON resulting in a Cyan colored light. The table below shows the values of the RGB LED output vector bits and their resulting light color.

<center>

**Note: There are three bits in the RGB LED's output resulting in 2<sup>3</sup>, or 8 different color combinations.**


|  Red  | Green | Blue |    Color    |
|:-----:|:-----:|:----:|:-----------:|
|   0   |   0   |  0   | **Off**     |
|   0   |   0   |  1   | **Blue**    |
|   0   |   1   |  0   | **Green**   |
|   0   |   1   |  1   | **Cyan**    |
|   1   |   0   |  0   | **Red**     |
|   1   |   0   |  1   | **Magenta** |
|   1   |   1   |  0   | **Yellow**  |
|   1   |   1   |  1   | **White**   |

</center>

<center>

Table 1. All possible color combinations

</center>

Consider moving down the table one row at a time (back up to the top once the last color is hit). It can be observed that every **one** row, the **Blue** bit is flipped. Additionally it can be noted that every **two** rows the **Green** bit it flipped. Finally, every **four** rows the **Red** bit is flipped. This pattern can be used to programatically cycle through all possible colors in the RGB LED. As described in the **Constraints** sections of this manual, the board will be using a clock with a period of 8 ns. This period results in a frequency of 125 MHz. Instead of changing the RGB bits every row, we can think of it in terms of clock cycles instead. However, having the bits change at a freuency of 125 MHz is far to fast for the human eye to observe, therefore we can use counters to convert our 125 MHz clock to a 1 Hz clock (Bits would change once every second). To do this, a constant of 125,000,000 is used as the max value for a counter. As before, it was observed that as the row changed, the Blue bit changed each row, or each cycle. A blue bit counter can be initialized to 0 and incremented each cycle until 125,000,000. At this point, one second has passed and the Blue bit can be toggled. Similarily, a green bit counter can be initialized to 0 and incremented each cycle until 2 x 125,000,000. It is multiplied by 2 because the green bit only changes once every two cycles. Lastly, a red bit counter can be initialized to 0 and incremented until 4 x 125,000,000, multipled by 4 because the red bit only changes once every four cycles. The process for RGB LED 0 is shown below and a similar process can be made for RGB LED 1.

```vhdl
-- Process to control RGB LED 0
led0_RBG_green_proc : process
variable red_counter : integer := 0;
variable green_counter : integer := 0;
variable blue_counter : integer := 0;
begin
    -- Evaluate on rising edge of 8 ns clock
    if rising_edge(clk) then
        -- If the switch is in the ON position, allow the bits to be evaluated
        if sw0 = '1' then 
            -- Update RED once a clock cycle
            if red_counter = clk_period-1 then
                led0_RGB(2) <= NOT led0_RGB(2);
                red_counter := 0;
            else
                red_counter := red_counter + 1;
            end if;
            
            -- Toggle GREEN once every 2 clock cycles 
            if green_counter = (2*clk_period)-1 then
                led0_RGB(1) <= NOT led0_RGB(1);
                green_counter := 0;
            else
                green_counter := green_counter + 1;
            end if;
            
            -- Toggle BLUE once every 4 clock cycles
            if blue_counter = (4*clk_period)-1 then
                led0_RGB(0) <= NOT led0_RGB(0);
                blue_counter := 0;
            else
                blue_counter := blue_counter + 1;
            end if;   
        else
            -- If switch if OFF, turn RGB LED OFF
            led0_RGB <= "000";
        end if; 
    end if;
end process;
```
At this point, our VHDL program is complete. However, we need to connect our program to the deveopment board. This is done using constraints and will be discussed in the next section.


## Constraints
To connect our VHDL program to the development board, a constraint file needs to be created. This file informs the software what physical pins on the FPGA our program plans to use. Different developmnent boards all have different I/O pins and features, therefore constraints for each different type of board willbe different. The constraint file for the Arty Z7 board can be found [here](https://github.com/Digilent/digilent-xdc/blob/master/Arty-Z7-20-Master.xdc). To import this file into our project, select the '+' button in the 'Sources' tab and choose "Add or create constraints". The constraint file linked above can be downloaded or copied. If downloaded, select "Add Files" and import the downloaded file. If copied, select "Create File", and give the file a meaningful name (ie. Arty_Z7_7020). Select "Finish" to complete the process.

Once created, open the constraint file by double clicking on it. In this file, all constraints are commented out by default and we can uncomment the pins that relate to our program. Conveniently, all pins related to our program are at the top. Uncomment (remove the "#" symbol) from all lines relating to the Clock Signal, Switches, RGB LEDs, LEDs and Buttons. Now that the physical pins are available, the port names that we used in the programs design needs to be connected to the pins. To do this, replace the signals after the `get_ports` command with the name of the port names from the program. In the clock signal declaration, a period of 8 ns is created using the `-period 8` syntax. Additionally, this clock has 0 phase shift and also has a 50% duty cycle as defined by the `-waveform {0 4}` syntax (on for 4 ns out of 8 ns). The resulting file should look similar to the following.

```
## Clock Signal
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=SYSCLK
create_clock -add -name sys_clk_pin -period 8 -waveform {0 4} [get_ports { clk }];#set

## Switches
set_property -dict { PACKAGE_PIN M20    IOSTANDARD LVCMOS33 } [get_ports { sw0 }]; #IO_L7N_T1_AD2N_35 Sch=SW0
set_property -dict { PACKAGE_PIN M19    IOSTANDARD LVCMOS33 } [get_ports { sw1 }]; #IO_L7P_T1_AD2P_35 Sch=SW1

## RGB LEDs
set_property -dict { PACKAGE_PIN L15    IOSTANDARD LVCMOS33 } [get_ports { led0_RGB[0] }]; #IO_L22N_T3_AD7P_35 Sch=LED4_B
set_property -dict { PACKAGE_PIN G17    IOSTANDARD LVCMOS33 } [get_ports { led0_RGB[1] }]; #IO_L16P_T2_35 Sch=LED4_G
set_property -dict { PACKAGE_PIN N15    IOSTANDARD LVCMOS33 } [get_ports { led0_RGB[2] }]; #IO_L21P_T3_DQS_AD14P_35 Sch=LED4_R
set_property -dict { PACKAGE_PIN G14    IOSTANDARD LVCMOS33 } [get_ports { led1_RGB[0] }]; #IO_0_35 Sch=LED5_B
set_property -dict { PACKAGE_PIN L14    IOSTANDARD LVCMOS33 } [get_ports { led1_RGB[1] }]; #IO_L22P_T3_AD7P_35 Sch=LED5_G
set_property -dict { PACKAGE_PIN M15    IOSTANDARD LVCMOS33 } [get_ports { led1_RGB[2] }]; #IO_L23N_T3_35 Sch=LED5_R

## LEDs
set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports { led0 }]; #IO_L6N_T0_VREF_34 Sch=LED0
set_property -dict { PACKAGE_PIN P14    IOSTANDARD LVCMOS33 } [get_ports { led1 }]; #IO_L6P_T0_34 Sch=LED1
set_property -dict { PACKAGE_PIN N16    IOSTANDARD LVCMOS33 } [get_ports { led2 }]; #IO_L21N_T3_DQS_AD14N_35 Sch=LED2
set_property -dict { PACKAGE_PIN M14    IOSTANDARD LVCMOS33 } [get_ports { led3 }]; #IO_L23P_T3_35 Sch=LED3

## Buttons
set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L4P_T0_35 Sch=BTN0
set_property -dict { PACKAGE_PIN D20    IOSTANDARD LVCMOS33 } [get_ports { btn1 }]; #IO_L4N_T0_35 Sch=BTN1
set_property -dict { PACKAGE_PIN L20    IOSTANDARD LVCMOS33 } [get_ports { btn2 }]; #IO_L9N_T1_DQS_AD3N_35 Sch=BTN2
set_property -dict { PACKAGE_PIN L19    IOSTANDARD LVCMOS33 } [get_ports { btn3 }]; #IO_L9P_T1_DQS_AD3P_35 Sch=BTN3

```
At this point, the program is completed and has been connected to the physical pins on the Arty Z7 development board. Next, the design must be Synthesized and Implemented onto the physical board for testing.

## Running and Testing
Before the design can be put onto the board, it must be Synthesized, Implemented and have the Bitstream generated. When running these steps, leave all values in their run menu's default. To do this, select "Run Synthesis" in the menu on the left hand side. This step may take a few minutes to complete. Once finished, select "Run Implementation" in the menu on the left hand side. Once complete select "Generate Bitstream" in the menu on the left hand side. Once finished, the design can be programmed to the board for testing. Connect the Arty Z7 board to the computer using a micro-usb cable. The board should automatically turn on with USB power. Once connected, select "Open Target" in the "Open Hardware Manager" menu on the left hand side. Selecting "Auto connect" should make Vivado automatically search for and connect to the Arty Z7 board. Finally, once the device is connected selected "Program Device" in the "Open Hardware Manager" menu on the left hand side followed by selected the boards part number. Ensure the bitstream file is correctly located in the popup (likely default) and select "Program". After a moment the design will be on the development board.

First the buttons behaviour will be tested. By pressing each of the 4 buttons, their corresponding LED above should light up. Once released, the LED should turn off. It can be observed that multiple buttons can be pressed at the same time, unaffecting the behaviour of the button/LED combination next to it. Again, this is because of the concurrent nature of the VHDL processes created for each button and LED combination. This testing confirms the behaviour of the buttons and LEDs.

Next the switches and RGB LEDs are tested. When the switches are in the OFF position, there should be no light emitted from the RGB LED above them. Once put into the ON position, the RGB LED should begin cycling through all possible color combinations as shown in Table 1. By observing all color combinations while the switches are in the ON position, the behaviour of the switches and RGB LEDs can be verified making the testing complete.

## Conclusion
This tutorial was designed and created as an introduction to Vivado, VHDL, and the Arty Z7 development board. A simple program was created to define the behaviour for onboard Buttons, LEDs, Switches and RGB LEDs. When buttons were pressed, the LEDs would turn on, and when the buttons were not pressed, turn off. Switches were used to turn on RGB LEDs. When they were on, they would cycle through all possible color combinations resulting from 3 bits of output. The design was programatically connected to the Arty Z7 board using a constaraint file which defined which physical pins would be used in the design, and which port names were used for each phsyical pin. The design was synthesized, implemented, bitstream generated, and lastly programmed to the board, Through physical testing, it was confirmed the behaviour of all desiged I/O devices was verified making this tutorial a success.
