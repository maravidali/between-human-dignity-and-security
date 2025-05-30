import os
import pandas as pd
import json
from typing import List

# Read config json
script_dir = os.path.dirname(os.path.abspath(__file__))

# Move up one directory to find the config.json file
project_root = os.path.dirname(script_dir)
config_path = os.path.join(project_root, "config.json")

with open(config_path, "r") as config:
    config_dict = json.load(config)

stopwords_path = config_dict["stopwords excel path"]

# Read stopwords from excel file
stop_words_df = pd.read_excel(stopwords_path, sheet_name="stopwords")

# Read additional stopwords from txt file
additional_stopwords = []
with open(config_dict["additional_stopwords_path"], "r") as f:
    for line in f:
        line = line.strip()
        if line:
            additional_stopwords.append(line)

# Read stopwords to keep from txt file
keep_stopwords = []
with open(config_dict["keep_stopwords_path"], "r") as f:
    for line in f:
        line = line.strip()
        if line:
            keep_stopwords.append(line)

# Read additional topic stopwords from txt file
additional_topic_stopwords = []
with open(config_dict["additional_topic_stopwords_path"], "r") as f:
    for line in f:
        line = line.strip()
        if line:
            additional_topic_stopwords.append(line)


def initialize_stopwords() -> List[str]:
    """
    Initialize stopwords list from excel file and append some custom stopwords.

    Returns:
    -------
    List[str]: A list of stopwords.
    """
    # Create list of stopwords
    stop_words = stop_words_df.word.values.tolist()

    # Removing/Appending stop words below because they might be usefull
    for add_stopword in additional_stopwords:
        stop_words.append(add_stopword)
    for keep_stopword in keep_stopwords:
        stop_words.remove(keep_stopword)

    return stop_words


def initialize_topic_stopwords() -> List[str]:
    """
    Initialize topic stopwords list from excel file and append some custom stopwords.

    Returns:
    -------
    List[str]: A list of topic stopwords.

    """
    # Create list of topic stopwords
    topic_stop_words = stop_words_df.topic_word.values.tolist()

    # Removing/Appending stop words below because they might be usefull
    for add_stopword in additional_topic_stopwords:
        topic_stop_words.append(add_stopword)

    return topic_stop_words
