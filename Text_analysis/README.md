## Python Setup Instructions

Before running the Jupyter Notebook, please follow these steps:

1. **Download and Install Anaconda**  
    [Download Anaconda](https://www.anaconda.com/products/distribution) and follow the installation instructions for your operating system.

2. **Create a Virtual Environment**  
    Open the Anaconda Prompt and run:  
    ```bash
    conda create -n ENV_NAME python=3.7.16
    ```

3. **Activate the Environment**  
    In the Anaconda Prompt, activate your environment:  
    ```bash
    conda activate ENV_NAME
    ```

4. **Install Dependencies**  
    Install the required packages:  
    ```bash
    pip install -r requirements.txt
    ```

5. **Fix Greek Stemmer Encoding Issue**  
    After installing dependencies, update the Greek Stemmer package:  
    - Navigate to:  
      ```
      C:\Users\YOUR_PATH\anaconda3\envs\ENV_NAME\Lib\site-packages\greek_stemmer\__init__.py
      ```
    - Open the file and search for `os.path.dirname(__file__)`.
    - Locate the line:
      ```python
      os.path.dirname(__file__), 'stemmer.yml'), 'r') as f:
      ```
    - Change it to:
      ```python
      os.path.dirname(__file__), 'stemmer.yml'), 'r', encoding='utf8') as f:
      ```

6. **Install Jupyter Notebook**  
    In the Anaconda Prompt, run:  
    ```bash
    pip install jupyter
    ```

7. **Navigate to the Project Directory**  
    Change your working directory to `Text_analysis`

8. **Launch Jupyter Notebook**  
    In the Anaconda Prompt, start Jupyter Notebook:
    ```bash
    jupyter notebook
    ```

9. **Open the Notebook**  
    In the Jupyter interface, open `text_analysis.ipynb` in `final notebooks (Python)`.

10. **Run the Notebook**  
     Execute each code cell in order.

11. **View Output Figures**  
     Generated figures will be saved in the local `figures` directory (Figures 7, 8, 12 ,13).


After running succesfully the Python jupyter notebook, please proceed with the R notebook.
## R Setup Instructions
Before running the Jupyter Notebook, please follow these steps:
1. [Download](https://cran.r-project.org/bin/windows/base/old/4.3.0) R version 4.3.0 (2023-04-21 ucrt)
2. Follow the environment specifications included in the shared `session_info.txt`
3. Open Anaconda prompt
4. **Navigate to the Project Directory**  
    Change your working directory to `Text_analysis`
5. **Activate the Environment**  
    In the Anaconda Prompt, activate your environment (Already created virtual environment):  
    ```bash
    conda activate ENV_NAME
    ```
6. Install `irkernel`
    ```bashP
    conda install -c conda-forge r-base r-irkernel
    ```
6. In the Anaconda Prompt, start Jupyter Notebook:
    ```bash
    jupyter notebook
    ```
7. **Open the Notebook**  
    In the Jupyter interface, open `text_analysis.ipynb` in `final notebooks (R)`.
8. **Run the Notebook**  
     Execute each code cell in order.
9. **View Output Figures**  
     Generated figures will be saved in the local `figures` directory (Figures 6, C2, C3).