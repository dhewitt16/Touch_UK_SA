Code to process behavioural data

Behavioural data from PsychoPy
Programmes: Python, run in Jupyter Notebooks

1.	Use search bar in system File Explorer to get all *.csv files for all participants
2.	Copy and paste these *.csv files into a new folder in working directory called input_files - it does not matter that they are not within the individual participant folder as the participant information is stored in the csv itself.
3.	Create a folder called output_files
4.	Run concatenateCSV to add all individual subject data into one large spreadsheet called allBehaviouralData.csv
5.	Run RecodeBehaviouralData to open the big csv file - this makes a new csv which is formatted for analysis
   
a.It firstly loads the columns we will use and removes spaces in the column names 

b.	Next, it recodes the experimental conditions 'Practice' and 'Main Experiment' to 1 and 2, respectively

c.	The current block information is stored inside Block Number and the 2 Block Orders columns – to make analysis easier, new columns have been created to specify the current block for each individual line

d.	First, it creates a new column to specify the touch speed condition called 'Speed_Cond', where 1 = Slow, 2 = Fast

e.	Then, it creates a new column to specify the touch location called ‘Loc_Cond’

f.	The touch location is recoded numerically, where Palm = 1, arm = 2, other = 3, self = 4 (these could also be recoded if necessary into 1 and 2 for each study, but for now they are kept distinct)

g.	Data are stored into a new spreadsheet called ‘allBehaviouralData_recoded.csv’

7.	These steps could be combined into 1 script for simplicity, but are not at the moment
