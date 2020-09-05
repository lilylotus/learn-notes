# POI 概述

HSSF 是 POI 项目中纯 Java 实现处理 Excel 97-2007 的格式 (.xls)，每个 sheet 限制在 65535 行，一般不会 OOM
XSSF 是 POI 项目用纯 Java 实现 Excel 2007 OOXML (.xlsx) 的格式。(1048576行，16384列)，伴随着 OOM 问题
3.8 版本后 SXSSF 是一个 API 兼容对 XSSF 的一种流式扩展，当处理十分大的电子表格和堆空间受限。特点是采用了滑动窗口的机制，低内存占用