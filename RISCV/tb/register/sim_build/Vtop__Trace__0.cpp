// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals

#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtop___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0\n"); );
    // Body
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    Vtop___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0_sub_0\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    bufp->chgBit(oldp+0,(vlSelfRef.clk));
    bufp->chgBit(oldp+1,(vlSelfRef.rst_n));
    bufp->chgCData(oldp+2,(vlSelfRef.address1),5);
    bufp->chgCData(oldp+3,(vlSelfRef.address2),5);
    bufp->chgIData(oldp+4,(vlSelfRef.read_data1),32);
    bufp->chgIData(oldp+5,(vlSelfRef.read_data2),32);
    bufp->chgBit(oldp+6,(vlSelfRef.write_enable));
    bufp->chgIData(oldp+7,(vlSelfRef.write_data),32);
    bufp->chgCData(oldp+8,(vlSelfRef.address3),5);
    bufp->chgBit(oldp+9,(vlSelfRef.regfile__DOT__clk));
    bufp->chgBit(oldp+10,(vlSelfRef.regfile__DOT__rst_n));
    bufp->chgCData(oldp+11,(vlSelfRef.regfile__DOT__address1),5);
    bufp->chgCData(oldp+12,(vlSelfRef.regfile__DOT__address2),5);
    bufp->chgIData(oldp+13,(vlSelfRef.regfile__DOT__read_data1),32);
    bufp->chgIData(oldp+14,(vlSelfRef.regfile__DOT__read_data2),32);
    bufp->chgBit(oldp+15,(vlSelfRef.regfile__DOT__write_enable));
    bufp->chgIData(oldp+16,(vlSelfRef.regfile__DOT__write_data),32);
    bufp->chgCData(oldp+17,(vlSelfRef.regfile__DOT__address3),5);
    bufp->chgIData(oldp+18,(vlSelfRef.regfile__DOT__registers[0]),32);
    bufp->chgIData(oldp+19,(vlSelfRef.regfile__DOT__registers[1]),32);
    bufp->chgIData(oldp+20,(vlSelfRef.regfile__DOT__registers[2]),32);
    bufp->chgIData(oldp+21,(vlSelfRef.regfile__DOT__registers[3]),32);
    bufp->chgIData(oldp+22,(vlSelfRef.regfile__DOT__registers[4]),32);
    bufp->chgIData(oldp+23,(vlSelfRef.regfile__DOT__registers[5]),32);
    bufp->chgIData(oldp+24,(vlSelfRef.regfile__DOT__registers[6]),32);
    bufp->chgIData(oldp+25,(vlSelfRef.regfile__DOT__registers[7]),32);
    bufp->chgIData(oldp+26,(vlSelfRef.regfile__DOT__registers[8]),32);
    bufp->chgIData(oldp+27,(vlSelfRef.regfile__DOT__registers[9]),32);
    bufp->chgIData(oldp+28,(vlSelfRef.regfile__DOT__registers[10]),32);
    bufp->chgIData(oldp+29,(vlSelfRef.regfile__DOT__registers[11]),32);
    bufp->chgIData(oldp+30,(vlSelfRef.regfile__DOT__registers[12]),32);
    bufp->chgIData(oldp+31,(vlSelfRef.regfile__DOT__registers[13]),32);
    bufp->chgIData(oldp+32,(vlSelfRef.regfile__DOT__registers[14]),32);
    bufp->chgIData(oldp+33,(vlSelfRef.regfile__DOT__registers[15]),32);
    bufp->chgIData(oldp+34,(vlSelfRef.regfile__DOT__registers[16]),32);
    bufp->chgIData(oldp+35,(vlSelfRef.regfile__DOT__registers[17]),32);
    bufp->chgIData(oldp+36,(vlSelfRef.regfile__DOT__registers[18]),32);
    bufp->chgIData(oldp+37,(vlSelfRef.regfile__DOT__registers[19]),32);
    bufp->chgIData(oldp+38,(vlSelfRef.regfile__DOT__registers[20]),32);
    bufp->chgIData(oldp+39,(vlSelfRef.regfile__DOT__registers[21]),32);
    bufp->chgIData(oldp+40,(vlSelfRef.regfile__DOT__registers[22]),32);
    bufp->chgIData(oldp+41,(vlSelfRef.regfile__DOT__registers[23]),32);
    bufp->chgIData(oldp+42,(vlSelfRef.regfile__DOT__registers[24]),32);
    bufp->chgIData(oldp+43,(vlSelfRef.regfile__DOT__registers[25]),32);
    bufp->chgIData(oldp+44,(vlSelfRef.regfile__DOT__registers[26]),32);
    bufp->chgIData(oldp+45,(vlSelfRef.regfile__DOT__registers[27]),32);
    bufp->chgIData(oldp+46,(vlSelfRef.regfile__DOT__registers[28]),32);
    bufp->chgIData(oldp+47,(vlSelfRef.regfile__DOT__registers[29]),32);
    bufp->chgIData(oldp+48,(vlSelfRef.regfile__DOT__registers[30]),32);
    bufp->chgIData(oldp+49,(vlSelfRef.regfile__DOT__registers[31]),32);
    bufp->chgIData(oldp+50,(vlSelfRef.regfile__DOT__unnamedblk1__DOT__i),32);
}

void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_cleanup\n"); );
    // Locals
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
