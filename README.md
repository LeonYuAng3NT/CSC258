# CSC258
Collections of labs and projects from CSC258

Project: 
  Description:Final version of course project. The milestones of the project has not been uploaded but there are in total three phases.
  
  The work of this project was distributed evenly and my partner and I combined work together and edited for the final version. Contat us for more information : RuoShui Yan 's github:https://github.com/yanrs17
                                            YuAng Zhang's github : https://github.com/LeonYuAng3NT
  
  Game Summary: A similar version of Doodle jump with different game mechanism. Player has to fall from upper blocks to lower blocks 
  in order to stay alive.  The game will be over if the player touches the top or fall on the bottom grid without standing beneath 
  a block. 
  
  Instructions: In order to compile the game, user has to download Quartus two and to prepare a DE1-SoC board with FPGA chips. 
  All softwares and hardwares are available in University of Toronto's Bahen Center of Inofrmation Technogloy building embedded System lab rooms. In order to compile the game, do the following:
  1. Open Quartus II and go to File > New... and select New Quartus II Project.
  2. Click Next and under Directory, Name, Top-Level Entity select your working directory and type the name
      of your project. The top-level design will automatically fill out to be the same name as your project.

  3. If you open Assignments > Pin Planner, you can see all the assignments of signal names to pin numbers
      (e.g., SW[0] to pin number PIN AB12).

  4. Once you have completed your design, click Processing > Start Compilation.
  5. When compilation is done, click Tools > Programmer and a window will appear.
  6. Go to Hardware Setup and ensure Currently Selected Hardware is DE1-SoC [USB-x] and close the window.
  7. Click Auto Detect and select 5CSEMA5 and click OK.
  8. Double click <none> for device 5CSEMA5 and load SOF file (usually under folder ”output files”) and
      device will change to 5CSEMA5F31.
  9. Ensure Program/Configure for device ”5CSEMA5F31 is checked and click Start.
  10. Play the game using the clock on Board.

Demo.v: A demo for showing how State logic works 



Datapath.v: Lab exercise of desiging a datapath which is able to perform specific operations by using a DE1-SoC board.


Sequence_101.v: Lab exercise of designing a sequence 101 detector by using verilog.






