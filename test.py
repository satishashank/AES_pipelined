import cocotb
from cocotb.triggers import Timer,FallingEdge,RisingEdge,NextTimeStep
from cocotb.clock import Clock
import random
from Crypto.Cipher import AES

async def driver(dut,data):
    while True:

        await RisingEdge(dut.clk)

        if(dut.data_ready.value):
            dut.dataIn.value = data
            dut.data_valid.value = 1
            await RisingEdge(dut.clk)
            dut.data_valid.value = 0
            break




class Monitor:
    def __init__(self, dut):
        self.dut = dut
        self.data = []
        self._run_coroutine_obj = None
        self._restart()

    
    def _restart(self) -> None:
        if self._run_coroutine_obj is not None:
            self._run_coroutine_obj.kill()
        self._run_coroutine_obj = cocotb.start_soon(self._run())
    
    def read_data(self):
        return (self.dut.dataOut.value)

    
    async def _run(self):
        while True:
            await RisingEdge(self.dut.clk)  # Sample *after* posedge updates
            await NextTimeStep()
            if self.dut.encryption_valid.value == 1:  # Check valid post-update
                self.data.append(self.read_data())
    




@cocotb.test()
async def test(dut):
    random.seed(42)
    clk = Clock(dut.clk, 1, "ns")
    cocotb.start_soon(clk.start())
    await Timer(5,"ns")
    dut.rst_n.value = 1
    await Timer(5,"ns")
    dut.rst_n.value = 0
    await Timer(5,"ns")
    dut.rst_n.value = 1
    monitor = Monitor(dut)
    await Timer(40,"ns")
    key = random.randbytes(16)
    key_int = int.from_bytes(key,"big")
    dut.key_in.value = key_int
    await RisingEdge(dut.clk)
    dut.key_valid.value = 1
    await RisingEdge(dut.clk)
    dut.key_valid.value = 0
    await driver(dut,0)
    
    cipher = AES.new(key,AES.MODE_ECB)
    count = 20
    encrypted_int_l = []
    encrypted_int_dut_l = []
    data_int_l = []
    for i in range(count):
        data = random.randbytes(16)
        data_int = (int.from_bytes(data,"big"))
        data_int_l.append(data_int)
        encrypted = cipher.encrypt(data)
        encrypted_int = int.from_bytes(encrypted,"big")
        encrypted_int_l.append(encrypted_int)
        await(driver(dut,data=data_int))
    await Timer (2000,"ns")
    wrong = 0
    index = 0
    encrypted_int_dut_l = monitor.data  # Assume len == count
    for i in range(count):
        a = hex(encrypted_int_dut_l[i+1])
        b = hex(encrypted_int_l[i])
        d = hex(data_int_l[i])  # Unused, but keep if logging
        cocotb.log.info(f"Index {index}: ({d},{a},{b})")
        if a != b:
            cocotb.log.error(f"Index {index} is wrong")
            wrong += 1
        index += 1

    cocotb.log.info(f"{wrong} wrong assertions")
    assert wrong == 0


    