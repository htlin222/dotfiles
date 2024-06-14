from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

def launchBrowser():
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
    driver.get("https://staff.kfsyscc.org/punch/")
    return driver

temperature = "36.4"

driver = launchBrowser()

# driver.FindElementById("outlined-adornment-weight").SendKeys (temperature)
# driver.FindElementByXpath("/html/body/div[3]/div[3]/div/div[2]/div[2]/div[1]/button[1]").Click
# driver.FindElementByXpath("/html/body/div[3]/div[3]/div/div[2]/div[2]/div[2]/button[1]").Click
# driver.FindElementByXpath("/html/body/div[3]/div[3]/div/div[2]/div[2]/div[3]/button[1]").Click
# driver.FindElementByXpath("/html/body/div[3]/div[3]/div/div[2]/div[2]/div[4]/button[1]").Click
# driver.FindElementByXpath("/html/body/div[3]/div[3]/div/div[3]/button").Click

