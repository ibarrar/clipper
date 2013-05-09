/*****
 *
 * NET.CH
 * Header file for the network functions
 *
 *
 */

#define     MAX_NOF_ATTEMPTS       10
#define     WAIT_TO_RETRY          1
#define     OS_SHARING_ERROR       32

#define     MSG_TRY_OPEN_FILE      "Attempting to open " +;
                                   "file ..."
#define     MSG_TRY_LOCK_REC       "Attempting to lock " +;
                                   "Record... ESC to cancel"
#define     MSG_LOCK_NO_SUCCESS    "Unable to lock Record..."
#define     MSG_TRY_LOCK_SEMAPH    "Attempting to lock " +;
                                   "semaphore file: "
#define     MSG_NO_SEMAPH_LOCK     "Unable to lock " +;
                                   "semaphore file: "

#define     MSG_COLOR              "N/BG*"
#define     MSG_TIME               2

#define     CloseSemaphore(handle)    (FCLOSE(handle))

// EOF - NET.CH //
