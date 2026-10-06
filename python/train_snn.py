import torch
import torch.nn as nn
import torch.optim as optim

X = torch.tensor([
    [1., 0., 1., 0.],
    [1., 0., 0., 1.],
    [0., 1., 1., 0.],
    [0., 1., 0., 1.]
])

y = torch.tensor([
    0,
    0,
    1,
    1
])

model = nn.Sequential(
    nn.Linear(4, 4),
    nn.ReLU(),
    nn.Linear(4, 2)
)

loss_fn = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.05)

for epoch in range(1000):
    optimizer.zero_grad()
    output = model(X)
    loss = loss_fn(output, y)
    loss.backward()
    optimizer.step()

with torch.no_grad():
    print("Predictions:")
    print(torch.argmax(model(X), dim=1))

    print("\nLayer 1 weights:")
    print(model[0].weight)

    print("\nLayer 1 bias:")
    print(model[0].bias)

    print("\nLayer 2 weights:")
    print(model[2].weight)

    print("\nLayer 2 bias:")
    print(model[2].bias)
