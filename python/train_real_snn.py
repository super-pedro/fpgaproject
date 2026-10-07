import torch
import torch.nn as nn
import snntorch as snn
from snntorch import surrogate

torch.manual_seed(1)

# Training patterns
X = torch.tensor([
    [1., 0., 1., 0.],
    [1., 0., 0., 1.],
    [0., 1., 1., 0.],
    [0., 1., 0., 1.]
])

y = torch.tensor([0, 0, 1, 1])

beta = 0.8
threshold = 1.0
num_steps = 20
scale = 32

spike_grad = surrogate.fast_sigmoid()

fc1 = nn.Linear(4, 4)

lif1 = snn.Leaky(
    beta=beta,
    threshold=threshold,
    spike_grad=spike_grad,
    reset_mechanism="zero"
)

fc2 = nn.Linear(4, 2)

lif2 = snn.Leaky(
    beta=beta,
    threshold=threshold,
    spike_grad=spike_grad,
    reset_mechanism="zero"
)

optimizer = torch.optim.Adam(
    list(fc1.parameters()) + list(fc2.parameters()),
    lr=0.02
)

loss_fn = nn.CrossEntropyLoss()

for epoch in range(500):

    mem1 = lif1.init_leaky()
    mem2 = lif2.init_leaky()

    spike_counts = torch.zeros(4, 2)

    for step in range(num_steps):

        # Deterministic spike input.
        # This matches holding the Basys 3 buttons.
        spikes_in = X

        cur1 = fc1(spikes_in)
        spk1, mem1 = lif1(cur1, mem1)

        cur2 = fc2(spk1)
        spk2, mem2 = lif2(cur2, mem2)

        spike_counts += spk2

    loss = loss_fn(spike_counts, y)

    optimizer.zero_grad()
    loss.backward()
    optimizer.step()


# Test network
with torch.no_grad():

    mem1 = lif1.init_leaky()
    mem2 = lif2.init_leaky()

    spike_counts = torch.zeros(4, 2)

    for step in range(100):

        cur1 = fc1(X)
        spk1, mem1 = lif1(cur1, mem1)

        cur2 = fc2(spk1)
        spk2, mem2 = lif2(cur2, mem2)

        spike_counts += spk2

    predictions = torch.argmax(spike_counts, dim=1)

    print("Spike counts:")
    print(spike_counts)

    print("\nPredictions:")
    print(predictions)


# Quantization
def quantize(tensor):
    q = torch.round(tensor * scale).to(torch.int32)
    q = torch.clamp(q, -128, 127)
    return q


w1 = quantize(fc1.weight)
b1 = quantize(fc1.bias)

w2 = quantize(fc2.weight)
b2 = quantize(fc2.bias)


print("\nQuantized Layer 1 weights:")
print(w1)

print("\nQuantized Layer 1 bias:")
print(b1)

print("\nQuantized Layer 2 weights:")
print(w2)

print("\nQuantized Layer 2 bias:")
print(b2)


# Memory layout:
#
# 0-15  = layer 1 weights
# 16-19 = layer 1 biases
# 20-27 = layer 2 weights
# 28-29 = layer 2 biases

values = []

for neuron in range(4):
    for inp in range(4):
        values.append(int(w1[neuron][inp]))

for neuron in range(4):
    values.append(int(b1[neuron]))

for neuron in range(2):
    for hidden in range(4):
        values.append(int(w2[neuron][hidden]))

for neuron in range(2):
    values.append(int(b2[neuron]))


# Write signed 8-bit values as hexadecimal two's complement
with open("weights.mem", "w") as f:
    for value in values:
        f.write(f"{value & 0xFF:02X}\n")


print("\nCreated weights.mem successfully.")
