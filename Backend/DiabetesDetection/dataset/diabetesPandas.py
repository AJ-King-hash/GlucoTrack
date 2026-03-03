import pandas as pd
import numpy as np
from pandas import DataFrame

class PandaModifier():
    def __init__(self,file:DataFrame,target_col):
        self.file=file
        self.target_col=file.loc[:,[target_col]].values
        self.heads=file.keys().to_list()
        self.inputs_col=file.loc[:,list(filter(lambda x:x!="Glycemic Index",self.heads))]
    def getTragets(self):
        numpy_modify=np.array(self.target_col)
        targets=numpy_modify.reshape(-1)
        return targets
    def getInputs(self):
        numpy_modify=self.inputs_col.values.tolist()
        return numpy_modify


file=pd.read_csv("DiabetesDetection/dataset/GI.csv")
panda_mod=PandaModifier(file,"Glycemic Index")     
arr_targets=panda_mod.getTragets()
arr_inputs=panda_mod.getInputs()
# print(arr_inputs)


