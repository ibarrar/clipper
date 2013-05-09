            case nKey==K_F3  //edit vchr only if !printed & !cancelled
                 if VOUCHER->CANCELLED
                    tone(300,3)
                    Message("Voucher is Cancelled, cannot be Edited...   any key to continue.")
                    inkey(0)
                 elseif VOUCHER->BILLED
                    tone(300,3)
                    Message("Voucher is Printed, cannot be Edited...   any key to continue.")
                    inkey(0)
                 else
                    TVForm(EDIT_MODE)
                 endif
