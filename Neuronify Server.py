from flask import request, jsonify, Flask
from flask_cors import CORS
from flask_ngrok import run_with_ngrok
import torch
import torch.nn as nn
import torch.nn.functional as f 
from torch.utils.data import TensorDataset, DataLoader
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
import os

GPU = torch.device("cuda")
def voidFunction(x):
    return x
activationFunctions = {
    1: f.relu,
    2: f.leaky_relu,
    3: f.tanh,
    4: voidFunction
}
optimizers = {
    1: torch.optim.Adam,
    2: torch.optim.SGD,
    3: torch.optim.RMSprop,
    4: torch.optim.Adagrad
}
mean_difference = 0

app = Flask(__name__)
run_with_ngrok(app)
CORS(app, resources={r"/api/*": {"origins": "*"}})


class CustomRegressor(nn.Module):
    def __init__(self, hiddenLayersData, x):
        self.hiddenLayersData = hiddenLayersData
        super().__init__()
        self.inputL = nn.Linear(np.size(x, axis=1), hiddenLayersData[1]['nodes']).to(GPU)
        self.hiddenLayers = []
        
        for hiddenLayer in hiddenLayersData:
            if hiddenLayer != max(list(hiddenLayersData.keys())):
                self.hiddenLayers.append(nn.Linear(hiddenLayersData[hiddenLayer]['nodes'], hiddenLayersData[hiddenLayer+1]['nodes']).to(GPU))
        self.hiddenLayers.append(nn.Linear(hiddenLayersData[max(list(hiddenLayersData.keys()))]['nodes'], 3).to(GPU))
        self.outputL = nn.Linear(3, 1).to(GPU)
        

    def forward(self, x):
        x = activationFunctions[1](self.inputL(x))
        for index, hiddenLayer in enumerate(self.hiddenLayers):
            x = activationFunctions[self.hiddenLayersData[index+1]['activationFunc']](hiddenLayer(x))
        return self.outputL(x)



@app.route("/trainModel", methods=["POST"])
def trainModel():
    requestBody = request.get_json()
    userID = requestBody['userID']
    hiddenLayersData = requestBody['hiddenLayersData']
    hiddenLayersData = {int(key): value for key, value in hiddenLayersData.items()}
    csv_data = requestBody['csv_data']
    n_epochs = requestBody['n_epochs']
    train_size = requestBody['train_size']
    batch_size = requestBody['batch_size']
    learning_rate = requestBody['learning_rate']
    optimizer_id = requestBody['optimizer_id']
    for row in csv_data[1:]:
        for i in range(len(row)):
            try:
                row[i] = float(row[i])
            except ValueError:
                pass
    dataset = pd.DataFrame(csv_data[1:], columns=csv_data[0])
    for column in dataset.columns:
        if dataset.dtypes[column] == 'object':
            dataset = dataset.drop(columns=[column])
    dataset = dataset.dropna()
    dataset.to_csv(f'{userID}.csv', index=False)

    x = dataset.iloc[:, :-1].values
    y = (dataset.iloc[:, -1].values).reshape(-1, 1)

    x_train, x_test, y_train, y_test = train_test_split(x, y, shuffle=True, train_size=train_size)
    train_dataset = TensorDataset((torch.tensor(x_train).float()).to(GPU), (torch.tensor(y_train).float()).to(GPU))
    train_loader = DataLoader( dataset= train_dataset, drop_last=True,batch_size=batch_size)
    test_dataset = TensorDataset((torch.tensor(x_test).float()).to(GPU), (torch.tensor(y_test).float()).to(GPU))
    test_loader = DataLoader( dataset = test_dataset, batch_size=len(test_dataset))

    regressor = CustomRegressor(hiddenLayersData, x).to(GPU)
    optimizer = optimizers[optimizer_id](params = regressor.parameters(), lr = learning_rate)
    loss_func = nn.MSELoss()


    for epoch in range(n_epochs):
        for x, y in train_loader:
            y_pred = regressor(x)
            loss = loss_func(y_pred, y)
            
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

    regressor.eval()
    with torch.no_grad():
        test_x, test_y = next(iter(test_loader))
        test_preds = regressor(test_x)
        mean_difference = torch.sqrt(torch.square(torch.mean(test_preds) - torch.mean(test_y))).item()
    torch.save(regressor, f'{userID}.pth')
    return jsonify({'MeanDifference': mean_difference}), 200



@app.route("/getInferenceMetaData", methods=["GET"])
def getInferenceMetaData():
    userID = request.args.get('userID')
    dataset = pd.read_csv(f'{userID}.csv')
    keysList = list(dataset.keys())
    return jsonify({"columns": keysList}), 200



@app.route("/getInference", methods=["POST"])
def getInference():
    userID = request.args.get('userID')
    requestBody = request.get_json()
    input = requestBody['input']
    model = torch.load(f'{userID}.pth')
    model.eval()
    with torch.no_grad():
        inference = model(torch.tensor(input).to(GPU)).item()
        return jsonify({"inference": inference}), 200
    

@app.route("/deleteModelData", methods=["GET"])
def deleteModelData():
    userID = request.args.get('userID')
    if os.path.exists(f'{userID}.pth'):
        os.remove(f'{userID}.pth')
    if os.path.exists(f'{userID}.csv'):
        os.remove(f'{userID}.csv')
    return '', 200

   
if __name__ == "__main__":
    app.run()
