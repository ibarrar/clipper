
/*============================================================================

        (c) 1993  TECHNO SOFTWARE CORPORATION

        This module contains information proprietary to TECHNO SOFTWARE
        CORPORATION, and should be treated confidential.

        MAKEDBF1.PRG/it600001.prg - Create PO, RR, RJ, ST, SA, V, 
                                    I, HR dbf and ntx.
                       Inventory Tracking System (ITS)

        acr / 03.28.93

============================================================================*/

#include "its.ch"
#include "dbstruct.ch"

FUNCTION makedbf1()
local aDbf := {}
local aStru, aNtx

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Purchase Order file set.
   AADD ( aStru, { "PO_001", "C",  8, 0, "Purchase Order Number"   } )     
   AADD ( aStru, { "PO_002", "C",  3, 0, "Vendor Code"             } )     
   AADD ( aStru, { "PO_003", "D",  8, 0, "Issue Date"              } )     
   AADD ( aStru, { "PO_004", "D",  8, 0, "Cancellation Date"       } )    
   AADD ( aStru, { "PO_005", "N",  1, 0, "Vendor Credit Terms"     } )     
   AADD ( aStru, { "PO_006", "N",  1, 0, "Purchase Order Status"   } )     
   AADD ( aStru, { "PO_007", "N",  2, 0, "Posting Status"          } )
   AADD ( aStru, { "PO_008", "D",  8, 0, "Posting Date"            } )   
   AADD ( aStru, { "PO_009", "N",  3, 0, "Terms Days"              } )   
   AADD ( aStru, { "PO_010", "N",  5, 2, "Percentage"              } )   
   AADD ( aStru, { "PO_011", "N",  5, 2, "Discount"                } )   
   AADD ( aStru, { "PO_012", "C", 20, 0, "Deliver to"              } )   
   AADD ( aStru, { "PO_013", "C",  9, 0, "Flag"                    } )   
   AADD ( aStru, { "PO_014", "C",  4, 0, "Class Code"              } )   
   AADD ( aStru, { "PO_015", "C", 15, 0, "Label"                   } )   
   AADD ( aStru, { "PO_016", "C", 15, 0, "Tag"                     } )   
   AADD ( aStru, { "PO_017", "D", 8, 0, "Delivery Date"            } )   
   AADD ( aStru, { "PO_018", "N", 1, 0, "OPFlag"                   } )   
   

   AADD ( aNtx,  { "PO_001", "PO_001", "Purchase Order Number"     } )     

   AADD ( aDbf,  { "PO", "Purchase Order - 1", aStru, aNtx } )

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Size file set.
   AADD ( aStru, { "POI_LINK", "C",  8,           0, "Link To PO"    } )
   AADD ( aStru, { "POI_ITEM", "C", PLU_CODE_LEN, 0, "Item Code"     } )
   AADD ( aStru, { "POI_DESC", "C", 40, 0, "Item Descrip"  } )
   AADD ( aStru, { "POI_COST", "N", 15,           2, "Unit Cost"     } )
   AADD ( aStru, { "POI_QORD", "N", 15,           3, "Qty Ordered"   } )
   AADD ( aStru, { "POI_UM",   "C", 10,           3, "Unit Measure"  } )
   AADD ( aStru, { "POI_URET", "N", 15,           2, "Unit Retail"  } )   
   AADD ( aStru, { "POI_QREC", "N", 15,           3, "Qty Received"  } )
   AADD ( aStru, { "POI_QRET", "N", 15,           3, "Qty Returned"  } )
   AADD ( aStru, { "POI_POST", "N",  2,           0, "Posting Status"} )
        
   AADD ( aNtx,  { "POI_LINK", "POI_LINK", "linking in PO" } )
   AADD ( aDbf,  { "PO_ITEMS", "PO Items", aStru, aNtx } )

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Supply Receipts file set.
   AADD ( aStru, { "RR_001", "C",  8, 0, "Receiving Report Number" } )     
   AADD ( aStru, { "RR_012", "C",  8, 0, "PO Reference Number" } )     
   AADD ( aStru, { "RR_002", "C",  3, 0, "Vendor Code"     } )     

   AADD ( aStru, { "RR_003", "C", 30, 0, "Vendor Name"   } )
   AADD ( aStru, { "RR_004", "C", 15, 0, "Receiving Personnel"      } ) 
        
   AADD ( aStru, { "RR_005", "D",  8, 0, "Transaction Date"        } )     
   AADD ( aStru, { "RR_006", "D",  8, 0, "Date Received"           } )     
   AADD ( aStru, { "RR_007", "N",  1, 0, "Reference Type"          } )     
   AADD ( aStru, { "RR_008", "C", 10, 0, "Reference Number"        } )     
   AADD ( aStru, { "RR_009", "D",  8, 0, "Reference Date"          } )     
   AADD ( aStru, { "RR_010", "N",  2, 0, "Posting Status"          } )
   AADD ( aStru, { "RR_011", "D",  8, 0, "Posting Date"            } )
   AADD ( aStru, { "RR_013", "N",  1, 0, "OPFLag"                  } )

   AADD ( aNtx,  { "RR_001", "RR_001", "Receiving Report Number"           } )
   AADD ( aDbf,  { "RR", "Supply Receipts - 2", aStru, aNtx } )


   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Size file set.
   AADD ( aStru, { "RRI_LINK", "C",  8,           0, "Link To RR"    } )
   AADD ( aStru, { "RRI_ITEM", "C", PLU_CODE_LEN, 0, "Item Code"     } )     
   AADD ( aStru, { "RRI_COST", "N", 15,           2, "Unit Cost"     } )
   AADD ( aStru, { "RRI_URET", "N", 15,           2, "Unit Retail"  } )   
   AADD ( aStru, { "RRI_QREC", "N", 15,           3, "Qty Received"  } )
   AADD ( aStru, { "RRI_POST", "N",  2,           0, "Posting Status"} ) 
   AADD ( aStru, { "RRI_AGEC", "C",  4,           0, "Age Code"      } )
   AADD ( aStru, { "RRI_SOLD", "N",  8,           0, "Qty Sold"      } )  
        
   AADD ( aNtx,  { "RRI_LINK", "RRI_LINK", "linking in RR" } )
   AADD ( aNtx,  { "RRI_COST", "RRI_ITEM+RRI_LINK+RRI_AGEC", "linking in RR" } )
   AADD ( aDbf,  { "RR_ITEMS", "RR Items", aStru, aNtx } )

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Stock Returns file set
   AADD ( aStru, { "RJ_001", "C",  8, 0, "Rejection Return Number" } )     
   AADD ( aStru, { "RJ_002", "C",  8, 0, "RR Reference Number"     } )     
   AADD ( aStru, { "RJ_003", "C",  3, 0, "Vendor code        "   } )
   AADD ( aStru, { "RJ_004", "C", 30, 0, "Vendor Name        "      } )
   AADD ( aStru, { "RJ_005", "D",  8, 0, "Transaction Date"        } )     
   AADD ( aStru, { "RJ_006", "D",  8, 0, "Date Received"           } )     
   AADD ( aStru, { "RJ_007", "N",  1, 0, "Reference Type"          } )
   AADD ( aStru, { "RJ_008", "C", 10, 0, "Reference Number"        } )     
   AADD ( aStru, { "RJ_009", "D",  8, 0, "Reference Date"          } )     
   AADD ( aStru, { "RJ_010", "N",  2, 0, "Posting Status"          } )     
   AADD ( aStru, { "RJ_011", "D",  8, 0, "Posting Date"            } )     
   AADD ( aStru, { "RJ_012", "N",  1, 0, "OPFlag"                  } )     

   AADD ( aNtx,  { "RJ_001", "RJ_001", "Rejection Return Number"   } )
   AADD ( aDbf,  { "RJ", "Stock Returns - 3", aStru, aNtx } )


   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Size file set.
   AADD ( aStru, { "RJI_LINK", "C",  8,           0, "Link To RJ"    } ) 
   AADD ( aStru, { "RJI_ITEM", "C", PLU_CODE_LEN, 0, "Item Code"     } )     
   AADD ( aStru, { "RJI_COST", "N", 15,           2, "Unit Cost"     } )
   AADD ( aStru, { "RJI_URET", "N", 15,           2, "Unit Retail"  } )   
   AADD ( aStru, { "RJI_QRET", "N", 15,           3, "Qty Returned"  } )
   AADD ( aStru, { "RJI_POST", "N",  2,           0, "Posting Status"} ) 
   AADD ( aStru, { "RJI_AGEC", "C",  4,           0, "Age Code"      } )
        
   AADD ( aNtx,  { "RJI_LINK", "RJI_LINK", "linking in RJ"           } )
   AADD ( aDbf,  { "RJ_ITEMS", "RJ Items", aStru, aNtx               } )
   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Stock Adjustment file set.
   AADD ( aStru, { "SA_001", "C",  8, 0, "Stock Adjustment Number" } )     
   AADD ( aStru, { "SA_002", "D",  8, 0, "Transaction Date"        } )
   AADD ( aStru, { "SA_003", "N",  2, 0, "Posting Status"          } )     
   AADD ( aStru, { "SA_004", "D",  8, 0, "Posting Date"            } )     
   AADD ( aStru, { "SA_005", "C",  3, 0, "Vendor Number" } )     
   AADD ( aStru, { "SA_006", "C",  20, 0, "Vendor Name" } )     
   AADD ( aStru, { "SA_007", "N",  1, 0, "OPFlag" } )     
   

   AADD ( aNtx,  { "SA_001", "SA_001", "Stock Adjustment Number"  } )
   AADD ( aDbf,  { "SA", "Stock Adjustment - 5", aStru, aNtx      } )


   // Initialize the arrays to empty
   aStru := {}
   aNtx := {}

   // Stock Adjustments
   AADD ( aStru, { "SAI_LINK", "C",  8,           0, "Stock Adj No"   } )
   AADD ( aStru, { "SAI_ITEM", "C", PLU_CODE_LEN, 0, ""     } )
   AADD ( aStru, { "SAI_UNIT", "C", 03,           0, ""     } )
   AADD ( aStru, { "SAI_QADJ", "N", 13,           3, "Quantity Adj"   } )
   AADD ( aStru, { "SAI_UPRC", "N", 15,           2, "Unit Cost"      } )
   AADD ( aStru, { "SAI_POST", "N",  2,           0, "Posting Status" } )

   AADD ( aNtx, { "SAI_LINK", "SAI_LINK", ""                 } )
   AADD ( aDbf, { "SA_ITEMS", "Stock Adj Items", aStru, aNtx } )

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Stock Transfer file set.
   AADD ( aStru, { "ST_001", "C",  8, 0, "Stock Transfer Number" } )
   AADD ( aStru, { "ST_002", "C",  3, 0, "Source Unit"           } )
   AADD ( aStru, { "ST_003", "C",  3, 0, "Destination Unit"      } )
   AADD ( aStru, { "ST_004", "D",  8, 0, "Transaction Date"      } )
   AADD ( aStru, { "ST_005", "N",  2, 0, "Posting Status"        } )     
   AADD ( aStru, { "ST_006", "D",  8, 0, "Posting Date"          } )     
   AADD ( aStru, { "ST_007", "C",  3, 0, "Vendor Number" } )     
   AADD ( aStru, { "ST_008", "C",  20, 0, "Vendor Name" } )     
   AADD ( aStru, { "ST_009", "N",  1, 0, "OPFlag" } )     

   AADD ( aNtx,  { "ST_001", "ST_001", "Stock Transfer Number"  } )
   AADD ( aDbf,  { "ST", "Stock Adjustment", aStru, aNtx      } )


   // Initialize the arrays to empty
   aStru := {}
   aNtx := {}

   // Stock Transfer Item Link
   AADD ( aStru, { "STI_LINK", "C",  8,           0, "Stock Trans No" } )
   AADD ( aStru, { "STI_ITEM", "C", PLU_CODE_LEN, 0, ""               } )
   AADD ( aStru, { "STI_QADJ", "N", 13,           3, "Quantity Trans" } )
   AADD ( aStru, { "STI_UPRC", "N", 15,           2, "Unit Cost"      } )         
   AADD ( aStru, { "STI_POST", "N",  2,           0, "Posting Status" } )

   AADD ( aNtx, { "STI_LINK", "STI_LINK", ""                 } )
   AADD ( aDbf, { "ST_ITEMS", "Stock Trans", aStru, aNtx } )      


   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Vendor file set.
   AADD ( aStru, { "V_001", "C",  3, 0, "Vendor Code"      } )     
   AADD ( aStru, { "V_002", "C", 30, 0, "Vendor 1"      } )     
   AADD ( aStru, { "V_003", "C", 50, 0, "Address 1"        } )     
   AADD ( aStru, { "V_004", "C", 30, 0, "Telephone Number" } )     
   AADD ( aStru, { "V_005", "C", 10, 0, "Fax Number"       } )     
   AADD ( aStru, { "V_006", "C", 20, 0, "Contact Person"   } )     
   AADD ( aStru, { "V_007", "C", 12, 0, "Tax ID Number"    } )     
   AADD ( aStru, { "V_008", "C", 12, 0, "VAT Number"       } )     
   AADD ( aStru, { "V_009", "N",  1, 0, "Credit Terms"     } )     
   AADD ( aStru, { "V_010", "N",  1, 0, "Vendor Type"      } )     
   AADD ( aStru, { "V_011", "C", 20, 0, "Item Supplied"      } )     
   AADD ( aStru, { "V_012", "N", 5, 2, "Percent"           } )     
   AADD ( aStru, { "V_013", "N", 1, 0, "OPFlag"            } )     
   AADD ( aStru, { "V_014", "C", 30, 0, "Vendor 2"      } )     
   AADD ( aStru, { "V_015", "C", 30, 0, "Vendor 3"      } ) 
   AADD ( aStru, { "V_016", "C", 30, 0, "Vendor 4"      } ) 
   AADD ( aStru, { "V_017", "C", 30, 0, "Vendor 5"      } )
   
   AADD ( aNtx,  { "V_001", "V_001", "Vendor Code" } )
   AADD ( aDbf,  { "V", "Vendor - 6", aStru, aNtx } )



   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Vendor file set.
   AADD ( aStru, { "BR_001", "C",  4, 0, "Brand Code"      } )     
   AADD ( aStru, { "BR_002", "C", 30, 0, "Brand Name"      } )     
   
   AADD ( aNtx,  { "BR_001", "BR_001", "Brand Code" } )
   AADD ( aNtx,  { "BR_002", "BR_002", "Brand Name" } )
   AADD ( aDbf,  { "BR", "Brand ", aStru, aNtx } )


   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Item file set.
   AADD ( aStru, { "I_001", "C", PLU_CODE_LEN, 0, "Item Code"              } )
   AADD ( aStru, { "I_002", "C", PLU_DESC_LEN, 0, "Descriptor"             } )
   AADD ( aStru, { "I_003", "N", 15, 2, "Selling Price"                    } )
   AADD ( aStru, { "I_004", "N",  2, 0, "Tax Rate"                         } )
   AADD ( aStru, { "I_005", "C", 10, 0, "Unit of Measure"                  } )
#ifdef CLASS_LINK
   AADD ( aStru, { "I_006", "C",  4, 0, "Class Number"                     } )
#else
   AADD ( aStru, { "I_006", "C",  2, 0, "Department No."                   } )
#endif   
   AADD ( aStru, { "I_007", "N", 15, 2, "Unit Cost"                        } )
   AADD ( aStru, { "I_008", "N", 13, 3, "Stock Balance"                    } )
   AADD ( aStru, { "I_009", "N", 10, 3, "Beginning Balance"                } )
   AADD ( aStru, { "I_010", "N", 10, 3, "Max. Level"                       } )
   AADD ( aStru, { "I_011", "N", 10, 3, "Min. Level"                       } )
   AADD ( aStru, { "I_012", "N", 10, 3, "Reorder Level"                    } )
   AADD ( aStru, { "I_013", "N", 10, 3, "Physical Count"                   } )
   AADD ( aStru, { "I_014", "D",  8, 0, "Date Received"                    } )
   AADD ( aStru, { "I_015", "D",  8, 0, "Stock Out Date"                   } )
   AADD ( aStru, { "I_016", "D",  8, 0, "Reorder Date"                     } )
   AADD ( aStru, { "I_017", "N", 15, 3, "ECR Quantity Sold"                } )
   AADD ( aStru, { "I_018", "N", 15, 2, "ECR Amount Sold"                  } )
   AADD ( aStru, { "I_019", "N",  1, 0, "POS Status"                       } )
   AADD ( aStru, { "I_020", "C",  3, 0, "Vendor Code "                     } )
   AADD ( aStru, { "I_021", "N", 15, 2, "Vendor Unit Cost"                 } )
   AADD ( aStru, { "I_022", "N", 10, 3, "Vendor Minimum Order Qty"         } )
        
   AADD ( aStru, { "I_023", "C", 12, 0, "Color"                            } )
   AADD ( aStru, { "I_024", "C", 12, 0, "Size"                             } )
   AADD ( aStru, { "I_025", "N",  2, 0, "Posting Status"                   } )
   AADD ( aStru, { "I_026", "D",  8, 0, "Posting Date"                     } )

   AADD ( aStru, { "I_027", "N", 15, 2, "Daily Sales Total"                } )
   AADD ( aStru, { "I_028", "N", 10, 3, "Daily Sales Count"                } )
   AADD ( aStru, { "I_029", "N", 15, 2, "Monthly Sales Total"              } )
   AADD ( aStru, { "I_030", "N", 10, 3, "Monthly Sales Count"              } )
   AADD ( aStru, { "I_031", "N", 15, 3, "Accum. Annual Sales Total"        } )
   AADD ( aStru, { "I_032", "N", 15, 2, "Accum. Annual Sales Count"        } )
   AADD ( aStru, { "I_033", "C", PLU_CODE_LEN, 0, "Stock Code"                       } )
   AADD ( aStru, { "I_034", "N",  7, 4, "Percentage Daily Sales"           } )
   AADD ( aStru, { "I_035", "N",  7, 4, "Percentage Monthly Sales"         } ) 
   AADD ( aStru, { "I_036", "N",  1, 0, "BarCode Check Digit"              } ) 
   AADD ( aStru, { "I_037", "C",  40, 0, "Item Descriptor"              } ) 
   AADD ( aStru, { "I_038", "C",  4, 0, "Age Code"              } ) 
   AADD ( aStru, { "I_039", "N",  1, 0, "OPFlag"              } ) 

   AADD ( aStru, { "I_040", "C",  4, 0, "Brand Code"  } )
   AADD ( aStru, { "I_041", "C",  25, 0, "Brand Name"  } )
   AADD ( aStru, { "I_042", "C",  4, 0, "Units Per Case" } )
   AADD ( aStru, { "I_043", "N", 15, 2, "Mark Up"   } )

   AADD ( aNtx,  { "I_001", "I_001", "Item Code"      } )
   AADD ( aNtx,  { "I_002", "I_002", "Item Desc"      } )
   AADD ( aNtx,  { "I_020", "I_020", "Item Supplier"      } )
   AADD ( aNtx,  { "I_006", "I_006", "Dept No."       } )  //added by jzo03-31-98
   AADD ( aNtx,  { "I_033", "I_033", "Stock Code"     } )
   AADD ( aNtx,  { "I_041", "I_041", "Brand Name"     } )
   AADD ( aDbf,  { "ITEM", "Items PLU File", aStru, aNtx } )


   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Size file set.
   AADD ( aStru, { "IV_LINK", "C", PLU_CODE_LEN, 0, "Link To Item" } )       
   AADD ( aStru, { "IV_CODE", "C",  3,           0, "Vendor Code"  } )     
   AADD ( aStru, { "IV_NAME", "C", 20,           0, "Vendor Name"  } )
   AADD ( aStru, { "IV_COST", "N", 15,           2, "Vendor Cost"  } )
   AADD ( aStru, { "IV_OQTY", "N", 15,           3, "Min.Qty.Ord." } )
   AADD ( aStru, { "IV_STCK", "N", 10,           3, "Remaining Stk"} )
   AADD ( aStru, { "IV_DATE", "D",  8,           0, "Date of Purchase"}) 
        
   AADD ( aNtx,  { "IV_LINK", "IV_LINK", "linking in I"            } )
   AADD ( aDbf,  { "IV",      "Items Vendor", aStru, aNtx          } )  

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Department file set.
   AADD ( aStru, { "DP_001", "C",  2, 0, "Dept. code  "    } )     
   AADD ( aStru, { "DP_002", "C", 25, 0, "Descriptor  "    } )        
   AADD ( aStru, { "DP_003", "N",  2, 0, "Group Number"    } )        
   AADD ( aStru, { "DP_004", "N", 15, 2, "Amount Limit"    } )     
   AADD ( aStru, { "DP_005", "C",  3, 0, "Concessionaire"  } )
   AADD ( aStru, { "DP_006", "D",  8, 0, "Start Date"      } )
   AADD ( aStru, { "DP_007", "D",  8, 0, "End Date"        } )
   AADD ( aStru, { "DP_008", "N",  7, 3, "Tax Rate"        } )
   AADD ( aStru, { "DP_009", "N",  7, 3, "Discount Rate"   } )
   AADD ( aStru, { "DP_010", "N", 12, 2, "HALO-High Amt Lock-Out" } )
   AADD ( aStru, { "DP_011", "N", 12, 2, "LALO-Low Amt Lock-Out" } )   
   AADD ( aStru, { "DP_012", "N", 1, 0, "OPFlag" } )   

   AADD ( aNtx,  { "DP_001", "DP_001", "Department Code"   } )
   AADD ( aDbf,  { "DP", "Department", aStru, aNtx } )

#ifdef CLASS_LINK
   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   AADD ( aStru, { "CL_001", "C",  4, 0, "Class Code"              } )     
   AADD ( aStru, { "CL_002", "C", 30, 0, "Descriptor"              } )     
   AADD ( aStru, { "CL_003", "C",  2, 0, "Dept. Link"              } )     
   AADD ( aStru, { "CL_004", "N", 15, 2, "Open to Buy Budget"      } )     
   AADD ( aStru, { "CL_005", "N", 15, 2, "Open to Buy Available"   } )     
   AADD ( aStru, { "CL_006", "N", 1, 0, "OPFlag"   } )     

   AADD ( aNtx,  { "CL_001", "CL_001", "Class Code"                } )
   AADD ( aDbf,  { "CL", "Class", aStru, aNtx } ) 
#endif

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}
   
   // CASHIER / SERVER 
   AADD ( aStru, { "CASH_CODE",     "C",  6, 0, "" } )
   AADD ( aStru, { "NAME",          "C", 20, 0, "" } )
   AADD ( aStru, { "TIME_IN",       "C",  6, 0, "" } )
   AADD ( aStru, { "TIME_OUT",      "C",  6, 0, "" } )
   AADD ( aStru, { "POS_NO",        "C",  4, 0, "" } )
   AADD ( aStru, { "RESERVED",      "C",  1, 0, "" } )   
*   AADD ( aStru, { "FLAG",          "C",  1, 0, "" } )   

   AADD ( aNtx,  { "CASHIER", "CASHIER->CASH_CODE",  "" } )   
   AADD ( aDbf,  { "CASHIER", "", aStru, aNtx } )

#ifdef CLERK   
   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // CLRK
   AADD ( aStru, { "CLERK_CODE",   "C", 06, 0, "" } )
   AADD ( aStru, { "CLERK_NAME",   "C", 20, 0, "" } )
   AADD ( aStru, { "SLSTOT",       "N", 10, 2, "" } )
   AADD ( aStru, { "SLSKNT",       "N", 04, 0, "" } )   
   AADD ( aStru, { "ITMKNT",       "N", 04, 0, "" } )   
   AADD ( aStru, { "RESERVED",     "C", 20, 0, "" } )   

   AADD ( aNtx,  { "CLRK", "CLRK->CLERK_CODE",  "" } )   
   AADD ( aDbf,  { "CLRK", "", aStru, aNtx } )         
#endif

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // Credit Cards
   AADD ( aStru, { "CC_001",   "C", 04, 0, "" } )
   AADD ( aStru, { "CC_002",   "C", 20, 0, "" } )
   AADD ( aStru, { "CC_003",   "N", 05, 0, "" } )
   AADD ( aStru, { "CC_004",   "N", 14, 2, "" } )   
   AADD ( aStru, { "CC_005",   "N", 1, 0, "" } )   

   AADD ( aNtx,  { "CC_001", "CC_001",  "" } )   
   AADD ( aDbf,  { "CC", "", aStru, aNtx } )         



   // Init Struc UNIT BRANCHES
   aStru := {}
   aNtx := {}

   AADD ( aStru, { "UNIT_CODE",  "C",  3, 0, "Unit Number"        } )
   AADD ( aStru, { "UNIT_NAME",  "C", 25, 0, "Unit Name"          } )
   AADD ( aStru, { "UNIT_ADDR",  "C", 25, 0, "Unit Address"       } )
   AADD ( aStru, { "UNIT_TSLS",  "N", 12, 2, "Target Sales"       } )
   AADD ( aStru, { "UNIT_DSLS",  "N", 15, 2, "Accum DLYSLS TTL"   } )
   AADD ( aStru, { "UNIT_DCNT",  "N", 13, 3, "Accum DLYSLS CNT"   } )
   AADD ( aStru, { "UNIT_DSUM",  "N", 15, 2, "Accum DSUM"         } )
   AADD ( aStru, { "UNIT_MSLS",  "N", 15, 2, "Accum MLYSLS TTL"   } )
   AADD ( aStru, { "UNIT_ASLS",  "N", 15, 2, "Accum ANLSLS TTL"   } )
   AADD ( aStru, { "UNIT_MDSUM", "N", 15, 2, "Accum Monthly DSUM" } )
   AADD ( aStru, { "UNIT_ADSUM", "N", 15, 2, "Accum Annual DSUM"  } )
   AADD ( aStru, { "UNIT_PATH",  "C", 50, 0, "UNIT PATH"          } )
   AADD ( aStru, { "UNIT_RATE",  "N", 07, 3, "UNIT Selling Rate"  } )
   AADD ( aStru, { "OP_FLAG",  "N", 01, 0, "OPFLag"  } )

   AADD ( aNtx,  { "UNIT", "UNIT_CODE","Unit Number" } )
   AADD ( aDbf,  { "UNIT", "Units", aStru, aNtx   } )

   // Init Struc UNIT BRANCHES MACHINES
   aStru := {}
   aNtx := {}

   AADD ( aStru, { "UNIT_LINK", "C",  3, 0, "LINK TO Unit Number"} )
   AADD ( aStru, { "MACHINENO", "C",  2, 0, "Unit MACHINE No"    } )
   AADD ( aStru, { "REMARKS"  , "C", 25, 0, "Unit Address"       } )
   AADD ( aStru, { "TARGETSLS", "N", 12, 2, "Target Sales"       } )
   AADD ( aStru, { "ACCUMDSLS", "N", 10, 2, "Accum DLYSLS TTL"   } )
   AADD ( aStru, { "ACCUMDCNT", "N", 09, 3, "Accum DLYSLS CNT"   } )
   AADD ( aStru, { "TAX",       "N", 15, 2, "Taxes"              } )
   AADD ( aStru, { "DISCOUNT",  "N", 15, 2, "Discounts"          } )
   AADD ( aStru, { "DSCT_CNT",  "N", 10, 3, "Discount Qty"       } )
   AADD ( aStru, { "VOID_ERR",  "N", 10, 3, "Void/Error Corr"    } )      
   AADD ( aStru, { "ACCUMMSLS", "N", 10, 2, "Accum MLYSLS TTL"   } )
   AADD ( aStru, { "ACCUMASLS", "N", 10, 2, "Accum ANLSLS TTL"   } )
   AADD ( aStru, { "ACCUMDSUM", "N", 10, 2, "Accum DSUM"         } )
   AADD ( aStru, { "ACCUMDSUM", "N", 10, 2, "Accum Monthly DSUM" } )
   AADD ( aStru, { "ACCUMDSUM", "N", 10, 2, "Accum Annual DSUM"  } )
   AADD ( aStru, { "UMAC_PATH", "C", 50, 0, "UNIT MACHINES PATH" } )
   AADD ( aStru, { "UMAC_RATE", "N", 07, 3, "MACHINE Selling Rate"} )

   AADD ( aNtx,  { "UM", "UNIT_LINK","Link To Unit Number" } )
   AADD ( aDbf,  { "UM", "Units", aStru, aNtx   } )

   // Foreign Structure
   aStru := {}
   aNtx := {}

   AADD ( aStru, { "F_CODE",   "C",  2, 0, "Foreign Currency Code" } )
   AADD ( aStru, { "F_ABBR",   "C",  3, 0, "Foreign Currency Abbr" } )
   AADD ( aStru, { "F_DESC",   "C", 25, 0, "Foreign Currency Desc" } ) 
   AADD ( aStru, { "F_DXCHG",  "N", 10, 6, "Xchange againts Dollar"} )
   AADD ( aStru, { "F_PXCHG",  "N", 10, 6, "Xchange againts Pesos" } )
   AADD ( aStru, { "F_DSLST",  "N", 15, 2, "Total Daily Sales"     } )
   AADD ( aStru, { "F_MSLST",  "N", 15, 2, "Total Monthly Sales"   } )
   AADD ( aStru, { "F_ASLST",  "N", 15, 2, "Total Annual Sales"    } )
   AADD ( aStru, { "F_PDXCG",  "N", 10, 6, "Previous Dollar Xchg"  } )
   AADD ( aStru, { "F_PPXCG",  "N", 10, 6, "Previous Peso Xchg"    } )
   AADD ( aStru, { "F_DECPOS", "N",  2, 0, "No. Decimal Position" } ) 
   AADD ( aStru, { "F_DATE",   "D",  8, 0, "Exchange Rate Date" } ) 

   AADD ( aNtx,  { "FOREIGN", "F_CODE", "Index key on Code "  } )
   AADD ( aDbf,  { "FOREIGN", "Foreign Currency", aStru, aNtx } )  

   // File Maintenance File
   aStru := {}
   aNtx := {}

   AADD ( aStru, { "TRANSNO", "N",   8, 0, "Trasaction no."     } )   
   AADD ( aStru, { "OP_CODE", "C",   2, 0, "Operation Code "    } ) 
   AADD ( aStru, { "FILE_ID", "C",   2, 0, "FileIdentification" } )
   AADD ( aStru, { "RECDATA", "C", 244, 0, "Data record"        } )
   AADD ( aStru, { "POSTDATE","D",   8, 0, "Date Posted"        } )
   AADD ( aStru, { "POSTSTAT","N",   1, 0, "Posting Status"     } )
   AADD ( aStru, { "OP_FLAG","N",   1, 0, "OPFlag"     } )

   AADD ( aNtx,  { "FM",     "TRANSNO", "Index on TRANSNO "  } )
   AADD ( aDbf,  { "FM", "File Maint File", aStru, aNtx } )

   // Terminal File
   aStru := {}
   aNtx := {}

   AADD ( aStru, { "TERM",       "C",   4, 0, " "  } )   
   AADD ( aStru, { "DATE",       "D",   8, 0, " "  } ) 
   AADD ( aStru, { "TIME",       "N",   2, 0, " "  } )
   AADD ( aStru, { "DAILY_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "DAILY_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "CASH_A",     "N",  14, 2, " "  } )
   AADD ( aStru, { "GROSS_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "DEPT_A",     "N",  14, 2, " "  } )
   AADD ( aStru, { "FORCUR_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "FORCUR_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC1_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC1_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC2_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC2_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC3_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC3_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC4_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC4_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC5_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC5_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC6_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC6_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC7_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC7_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC8_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC8_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC9_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC9_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC10_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC10_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC11_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC11_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC12_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC12_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC13_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC13_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC14_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC14_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC15_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC15_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC16_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC16_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC17_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC17_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC18_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC18_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC19_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC19_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC20_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC20_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC21_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC21_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC22_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC22_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC23_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC23_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC24_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC24_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC25_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC25_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC26_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC26_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC27_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC27_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC28_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC28_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC29_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC29_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC30_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC30_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC31_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC31_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC32_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC32_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC33_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC33_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC34_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC34_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC35_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC35_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC36_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC36_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC37_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC37_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC38_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC38_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC39_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC39_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC40_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC40_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC41_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC41_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC42_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC42_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC43_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC43_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC44_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC44_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC45_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC45_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC46_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC46_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC47_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC47_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC48_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC48_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC49_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC49_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC50_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC50_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "IVOID_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "IVOID_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MVOID_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MVOID_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "IDISC_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "IDISC_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SUBTD_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SUBTD_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "ADDON_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "ADDON_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SSBTD_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SSBTD_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SSBTA_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SSBTA_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "RETRN_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "RETRN_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "REFND_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "REFND_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "OTINC_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "OTINC_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "CANCL_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "CANCL_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "TVOID_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "TVOID_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SUSPD_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SUSPD_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "LAYAW_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "LAYAW_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "PIKUP_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "PIKUP_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "PDOUT_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "PDOUT_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "LOAN_C",     "N",   4, 0, " "  } )
   AADD ( aStru, { "LOAN_A",     "N",  14, 2, " "  } )
   AADD ( aStru, { "RECACT_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "RECACT_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "BOTDEP_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "BOTDEP_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "TRAIN_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "OFFLN_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "RENTER_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "OLDGRD_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "NEWGRD_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "XCOUNT_C",   "N",   6, 0, " "  } )
   AADD ( aStru, { "ZCOUNT_C",   "N",   6, 0, " "  } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )
   
   AADD ( aNtx,  { "TERMINAL", "TERMINAL->TERM+DTOS(TERMINAL->DATE)",  "" } )   
   AADD ( aDbf,  { "TERMINAL", "Terminal File", aStru, aNtx } )
       


  // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // PLU
   AADD ( aStru, { "DATE",   "D", 08, 0, "" } )
   AADD ( aStru, { "CODE",   "C", 14, 0, "" } )
   AADD ( aStru, { "ITEM_CODE",   "C", 12, 0, "" } )
   AADD ( aStru, { "DESC",   "C", 20, 0, "" } )
   AADD ( aStru, { "ICOUNT",  "N", 12, 2, "" } )
   AADD ( aStru, { "IAMOUNT", "N", 12, 2, "" } )
   AADD ( aStru, { "I_UCOST", "N", 12, 2, "" } )
   AADD ( aStru, { "WCOUNT",  "N", 12, 2, "" } )
   AADD ( aStru, { "WAMOUNT", "N", 12, 2, "" } )
   AADD ( aStru, { "W_UCOST", "N", 12, 2, "" } )      
   AADD ( aStru, { "OP_FLAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "PLU", "PLU->CODE+dtos(PLU->DATE)",  "" } )   
   AADD ( aNtx,  { "DATEPLU", "dtos(PLU->DATE) + PLU->CODE",  "" } )   
   AADD ( aNtx,  { "ITEMCNT", "PLU->ICOUNT",  "" } )   
   AADD ( aNtx,  { "AMTCNT",  "PLU->IAMOUNT",  "" } )
   AADD ( aDbf,  { "PLU", "", aStru, aNtx } )         

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // NOT FOUND PLU
   AADD ( aStru, { "DATE",   "D", 08, 0, "" } )
   AADD ( aStru, { "CODE",   "C", 14, 0, "" } )
   AADD ( aStru, { "ICOUNT",  "N", 12, 2, "" } )
   AADD ( aStru, { "IAMOUNT", "N", 12, 2, "" } )
   AADD ( aStru, { "I_UCOST", "N", 12, 2, "" } )
   AADD ( aStru, { "OP_FLAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "NPLU", "NPLU->CODE+dtos(NPLU->DATE)",  "" } )   
   AADD ( aNtx,  { "NITEMCNT", "NPLU->ICOUNT",  "" } )   
   AADD ( aDbf,  { "NPLU", "", aStru, aNtx } )         


    // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // PLU Temp
   AADD ( aStru, { "DATE",   "D", 08, 0, "" } )
   AADD ( aStru, { "CODE",   "C", 14, 0, "" } )
   AADD ( aStru, { "DESC",   "C", 20, 0, "" } )
   AADD ( aStru, { "ICOUNT",  "N", 12, 2, "" } )
   AADD ( aStru, { "IAMOUNT", "N", 12, 2, "" } )
   AADD ( aStru, { "I_UCOST", "N", 12, 2, "" } )
   AADD ( aStru, { "OP_FLAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "PLUTEMP", "PLUTEMP->CODE+dtos(PLUTEMP->DATE)",  "" } )   
   AADD ( aDbf,  { "PLUTEMP", "", aStru, aNtx } )         


    // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // DEPT
   AADD ( aStru, { "DATE",    "D", 08, 0, "" } )
   AADD ( aStru, { "DCODE",   "C", 04, 0, "" } )
   AADD ( aStru, { "DDESC",   "C", 20, 0, "" } )
   AADD ( aStru, { "DCOUNT",  "N", 12, 3, "" } )
   AADD ( aStru, { "DAMOUNT", "N", 12, 2, "" } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "DEPT", "DEPT->DCODE+DTOS(DEPT->DATE)",  "" } )   
   AADD ( aDbf,  { "DEPT", "", aStru, aNtx } )        


   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // HOURLY
   AADD ( aStru, { "TERM",   "C", 04, 0, "" } )
   AADD ( aStru, { "DATE",   "D", 08, 0, "" } )
   AADD ( aStru, { "TIME",   "N", 02, 0, "" } )
   AADD ( aStru, { "HOUR",   "N", 02, 0, "" } )
   AADD ( aStru, { "HCOUNT",  "N", 12, 3, "" } )
   AADD ( aStru, { "HAMOUNT", "N", 12, 2, "" } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "HOUR", "HOUR->HOUR",  "" } )   
   AADD ( aDbf,  { "HOUR", "", aStru, aNtx } )          


      // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // RETURN
   AADD ( aStru, { "DATE",     "D", 08, 0, "" } )
   AADD ( aStru, { "PLUCODE",  "C", 14, 0, "" } )
   AADD ( aStru, { "ITEMCODE",  "C", 12, 0, "" } )
   AADD ( aStru, { "RDESC",    "C", 20, 0, "" } )
   AADD ( aStru, { "RDEPT",    "C", 4, 0, "" } )
   AADD ( aStru, { "RCOUNT",   "N", 12, 3, "" } )
   AADD ( aStru, { "RAMOUNT",   "N", 14, 2, "" } )
   AADD ( aStru, { "RUCOST",   "N", 14, 2, "" } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "RET", "RET->PLUCODE+DTOS(RET->DATE)",  "" } )   
   AADD ( aNtx,  { "RETD", "RET->PLUCODE+RET->RDEPT",  "" } )   
   AADD ( aDbf,  { "RET", "", aStru, aNtx } )          

   
         // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // Control No.
   AADD ( aStru, { "CONTRL_NO",  "N", 04, 0, "" } )
   AADD ( aStru, { "DATE",       "D", 08, 0, "" } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )
   
   AADD ( aNtx,  { "CNTRL", "STR(CNTRL->CONTRL_NO)",  "" } )   
   AADD ( aNtx,  { "CDATE", "DTOS(CNTRL->DATE)" ,"" } )
   AADD ( aDbf,  { "CNTRL", "", aStru, aNtx } )          


   // Cashier File
   aStru := {}
   aNtx := {}

   AADD ( aStru, { "TERM",       "C",   4, 0, " "  } )   
   AADD ( aStru, { "DATE",       "D",   8, 0, " "  } ) 
   AADD ( aStru, { "TIME",       "N",   2, 0, " "  } )
   AADD ( aStru, { "CODE",       "C",   3, 0, " "  } )   
   AADD ( aStru, { "NAME",       "C",  20, 0, " "  } ) 
   AADD ( aStru, { "DAILY_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "DAILY_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "CASH_A",     "N",  14, 2, " "  } )
   AADD ( aStru, { "GROSS_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "DEPT_A",     "N",  14, 2, " "  } )
   AADD ( aStru, { "FORCUR_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "FORCUR_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC01_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC01_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC02_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC02_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC03_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC03_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC04_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC04_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC05_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC05_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC06_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC06_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC07_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC07_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC08_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC08_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC09_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC09_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC10_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC10_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC11_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC11_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC12_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC12_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC13_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC13_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC14_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC14_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC15_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC15_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC16_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC16_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC17_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC17_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC18_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC18_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC19_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC19_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC20_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC20_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC21_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC21_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC22_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC22_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC23_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC23_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC24_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC24_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC25_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC25_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC26_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC26_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC27_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC27_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC28_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC28_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC29_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC29_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC30_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC30_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC31_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC31_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC32_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC32_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC33_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC33_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC34_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC34_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC35_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC35_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC36_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC36_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC37_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC37_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC38_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC38_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC39_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC39_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC40_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC40_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC41_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC41_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC42_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC42_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC43_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC43_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC44_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC44_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC45_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC45_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC46_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC46_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC47_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC47_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC48_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC48_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC49_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC49_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MISC50_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "MISC50_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "IVOID_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "IVOID_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "MVOID_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "MVOID_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "IDISC_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "IDISC_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SUBTD_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SUBTD_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "ADDON_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "ADDON_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SSBTD_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SSBTD_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SSBTA_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SSBTA_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "RETRN_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "RETRN_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "REFND_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "REFND_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "OTINC_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "OTINC_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "CANCL_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "CANCL_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "TVOID_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "TVOID_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "SUSPD_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "SUSPD_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "LAYAW_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "LAYAW_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "PIKUP_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "PIKUP_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "PDOUT_C",    "N",   4, 0, " "  } )
   AADD ( aStru, { "PDOUT_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "LOAN_C",     "N",   4, 0, " "  } )
   AADD ( aStru, { "LOAN_A",     "N",  14, 2, " "  } )
   AADD ( aStru, { "RECACT_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "RECACT_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "BOTDEP_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "BOTDEP_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "CASHDEC",    "N",  14, 2, " "  } )
   AADD ( aStru, { "TRAIN_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "OFFLN_A",    "N",  14, 2, " "  } )
   AADD ( aStru, { "RENTER_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "OLDGRD_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "NEWGRD_A",   "N",  14, 2, " "  } )
   AADD ( aStru, { "XCOUNT_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "ZCOUNT_C",   "N",   4, 0, " "  } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )
   
   AADD ( aNtx,  { "CAS", "CASH->CODE",  "" } )   
   AADD ( aDbf,  { "CASH", "Cashier File", aStru, aNtx } )

/*
   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // CCD
   AADD ( aStru, { "DATE",        "D", 08, 0, "" } )
   AADD ( aStru, { "TERM",        "C", 04, 0, "" } )
   AADD ( aStru, { "CASH_CODE",   "C", 06, 0, "" } )   
   AADD ( aStru, { "BANK_CODE",   "C", 04, 0, "" } )
   AADD ( aStru, { "CCD_COUNT",   "N", 12, 2, "" } )
   AADD ( aStru, { "DENOM",       "N", 12, 2, "" } )
   AADD ( aStru, { "CCD_AMOUNT",  "N", 12, 2, "" } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )

   AADD ( aNtx,  { "CCD", "DTOS(CCD->DATE)+CCD->CASH_CODE+CCD->BANK_CODE+str(CCD->DENOM)",  "" } )   
   AADD ( aNtx,  { "CCASH", "DTOS(CCD->DATE)+CCD->BANK_CODE+STR(CCD->DENOM)",  "" } )
   AADD ( aDbf,  { "CCD", "", aStru, aNtx } )        
*/

      // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // CHARGE
   AADD ( aStru, { "POS_NO",       "C", 04, 0, "" } )
   AADD ( aStru, { "DATE",        "D", 08, 0, "" } )
   AADD ( aStru, { "TIME",        "C", 08, 0, "" } )   
   AADD ( aStru, { "CASH_CODE",   "C", 06, 0, "" } )
   AADD ( aStru, { "SLS_AMOUNT",  "N", 12, 2, "" } )   
   AADD ( aStru, { "PAY_TYPE",    "C", 04, 0, "" } )
   AADD ( aStru, { "ACCT_NO",      "C", 20, 0, "" } )
   AADD ( aStru, { "OP_FlAG",   "N",   1, 0, " "  } )   

   AADD ( aNtx,  { "PAYTYPE", "DTOS(CHARGE->DATE)+CHARGE->PAY_TYPE",  "" } )   
   AADD ( aNtx,  { "CHARGE", "DTOS(CHARGE->DATE)+CHARGE->POS_NO+CHARGE->PAY_TYPE",  "" } )   
   AADD ( aDbf,  { "CHARGE", "", aStru, aNtx } )              


#ifdef CLERK
   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}   

   // CLERK for report
   AADD ( aStru, { "DATE",        "D", 08, 0, "" } )
   AADD ( aStru, { "CLRK_CODE",   "C", 06, 0, "" } )
   AADD ( aStru, { "CLRK_NAME",   "C", 20, 0, "" } )
   AADD ( aStru, { "SLSKNT",      "N", 10, 0, "" } )   
   AADD ( aStru, { "SLSTOT",      "N", 14, 2, "" } )

   AADD ( aNtx,  { "CLERK", "CLERK->CLRK_CODE+DTOS(CLERK->DATE)",  "" } )   
   AADD ( aDbf,  { "CLERK", "", aStru, aNtx } )         

#endif


 
RETURN aDbf


