rv32 Core
=========

This project is a senior design / capstone project by several Computer Science students at the University of Kansas (KU) in Lawrence.

### Final Team
 - Aditi Darade ([@AditiDarade](https://github.com/AditiDarade))
 - Daniel Ginsberg ([@Daniel-Gins](https://github.com/Daniel-Gins))
 - Jarrod Grothusen ([@Andal01](https://github.com/Andal01))
 - Andrew Macgillivray ([@amacgillivray](https://github.com/amacgillivray)), Team Lead

### Other Contributors
 - Alex Archer ([@alexarcher721](https://github.com/alexarcher721)), Fall 2022

### Acknowledgements
With many thanks to Derrick Quinn, who conceived and pitched the idea, as well as Dr. Esam El-Araby and Minyoung Joshua Jeng for their advice and support.

## Project Lifecycle

The original goal of this project was to create a core based on the RISC-V ISA, specifically implementing the "V" extension for vector operations in order to better support applications such as machine learning. We began with little to no experience with verilog nor CPU implementations. 

#### Early Challenges
While we were all novices to chip design and HDL's, we started out with enthusiasm and hoped to take it all in stride. We encountered our first hurdle when we learned that the grading of the course required us to anticipate and list out all of the steps of development in advance, despite us not yet knowing what steps would be involved in this type of project. This lead to a confused approach, where we wound up listing and completing needless tasks in order to meet grading requirements. That approach earned us near-perfect grades, but ate up valuable time that we otherwise could've spent researching and finding ways to actually progress on the project. 

#### Defining the Project
Frustrated, we worked with the TA to figure out a way around the grading of the class, and then started to work on the code seen in the `/core/` folder. We:

 - chose verilog as our HDL language
 - researched the RISC-V ISA, 
 - researched how softcores worked and the pros/cons of baremetal execution
 - decided that our core should run an RTOS
 - learned about the extensions (other than v) that we would need
 - chose a target board (the Arty Z7-20) and ordered it
 - started working with Vitis and Vivado
 - planned our code based on the [5-stage pipeline](https://webriscv.dii.unisi.it/)
 - and, started to implement it.

Our plan was to model and test each component in a separate file, and stitch everything together using Vivado's block design tool. However, we quickly grew frustrated with the fragility and limitations of that tool. We were discouraged when our parts order was filled incorrectly, and again when we learned that one of our team members dropped out of the class.

#### The Final Project
In the Spring 2023 semester, we reconsidered our goals and targeted a more basic implementation of a RISCV core, making heavy reference to an implementation from @UltraEmbedded. By examining and rewriting that code (our version of it is in the `/re/` branch) we learned how to structure the project and implement certain features, such as pipeline control, that we were having trouble with. We are no longer expecting to implement the "V" extension, and will instead focus on getting a barebones RV32IM core to a synthesizable state, programming an FPGA with it, and loading / running an RTOS (any available linux kernel) on it.
