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