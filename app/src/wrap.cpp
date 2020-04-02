
#include "main.h"
#include "cmsis_os.h"
#include "eth.h"
#include "usart.h"
#include "usb_otg.h"
#include "gpio.h"


#include "diag.hpp"

#ifdef __cplusplus
extern "C" {
#endif

void UserTask(void *argument)
{
  /* USER CODE BEGIN UserTask */
  /* Infinite loop */
  for(;;)
  {
    HAL_GPIO_TogglePin( LD1_GPIO_Port, LD1_Pin );
    osDelay(250);
    HAL_GPIO_TogglePin( LD2_GPIO_Port, LD2_Pin );
    osDelay(250);
    HAL_GPIO_TogglePin( LD3_GPIO_Port, LD3_Pin );
    osDelay(250);

    auto ms = appDiag();
    HAL_GPIO_TogglePin( LD2_GPIO_Port , LD2_Pin );
    HAL_UART_Transmit(&huart3, (uint8_t*)ms.msg, ms.len , 1000);

  }
  /* USER CODE END UserTask */
}


#ifdef __cplusplus
}
#endif


