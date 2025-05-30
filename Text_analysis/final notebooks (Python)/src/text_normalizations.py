import os
import pandas as pd
import re
import numpy as np
from greek_stemmer import GreekStemmer
import nltk
import spacy
import warnings
import json
from typing import Dict, List, Tuple

from .stopwords import initialize_stopwords

# Read stopwords
stop_words = initialize_stopwords()

# Read config json
# Read config json
script_dir = os.path.dirname(os.path.abspath(__file__))

# Move up one directory to find the config.json file
project_root = os.path.dirname(script_dir)
config_path = os.path.join(project_root, "config.json")
with open(config_path, "r") as config:
    config_dict = json.load(config)

# Assign paths to variables
normalization_type = config_dict["normalization type"]

# Disable warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

# Download punkt from nltk
nltk.download("punkt")

# Load Greek corpus from spacy
nlp = spacy.load("el_core_news_lg")

# Create instance of GreekStemmer
stemmer = GreekStemmer()


# Defining functions
def accent_remover(text: str) -> str:
    """
    Removes accents from Greek text.

    Args:
    ----
    text (str): Input text to be cleaned.

    Returns:
    -------
    str: Cleaned text with accents removed.

    """
    # Converting all characters to lowercase
    cleaned_text = text.lower()

    # Removing accents
    cleaned_text = re.sub("ά", "α", cleaned_text)
    cleaned_text = re.sub("έ", "ε", cleaned_text)
    cleaned_text = re.sub("ή", "η", cleaned_text)
    cleaned_text = re.sub("ί", "ι", cleaned_text)
    cleaned_text = re.sub("ό", "ο", cleaned_text)
    cleaned_text = re.sub("ύ", "υ", cleaned_text)
    cleaned_text = re.sub("ώ", "ω", cleaned_text)
    cleaned_text = re.sub("ϊ", "ι", cleaned_text)
    cleaned_text = re.sub("ϋ", "υ", cleaned_text)
    cleaned_text = re.sub("ΐ", "ι", cleaned_text)
    cleaned_text = re.sub("ΰ", "υ", cleaned_text)

    return cleaned_text


def stop_word_remover(text: str, stop_words: List[str]) -> str:
    """
    Removes stop words from the input text.

    Args:
    ----
    text (str): Input text to be cleaned.
    stop_words (List[str]): List of stop words to be removed.

    Returns:
    -------
    str: Cleaned text with stop words removed.

    """
    cleaned_text = text

    for i in range(len(stop_words)):
        # Removing stop words
        cleaned_text = re.sub(
            f"(\s+{stop_words[i]}\s+)|(^{stop_words[i]}\s+)|(\.\s?{stop_words[i]}\s+)|(\s+{stop_words[i]}\.\s?)",
            " ",
            cleaned_text,
        )
        cleaned_text = re.sub(
            f"(\s+{accent_remover(stop_words[i])}\s+)|(^{accent_remover(stop_words[i])}\s+)|(\.\s?{accent_remover(stop_words[i])}\s+)|(\s+{accent_remover(stop_words[i])}\.\s?)",
            " ",
            cleaned_text,
        )
        cleaned_text = re.sub(f"\s{stop_words[i]}\s", " ", cleaned_text)

    return cleaned_text


def text_normalizer(text: str) -> str:
    """
    Normalizes the input text by removing accents, substituting Latin characters with Greek letters,

    Args:
    ----
    text (str): Input text to be normalized.

    Returns:
    -------
    str: Normalized text with accents removed and Latin characters substituted with Greek letters.

    """
    # Converting all characters to lowercase
    cleaned_text = text.lower()

    # Removing accents
    cleaned_text = accent_remover(cleaned_text)

    # Substituting all latin characters with Greek letters
    # More specifically it substitutes only the patterns --> e.g. siziτηση and συζητηsi
    rgx = re.findall(r"([a-zA-z]+[α-ωΑ-Ω]+)|([α-ωΑ-Ω]+[a-zA-z]+)", cleaned_text)
    if type(rgx) == list:
        cleaned_text = re.sub("a", "α", cleaned_text)
        cleaned_text = re.sub("b", "μπ", cleaned_text)
        cleaned_text = re.sub("d", "δ", cleaned_text)
        cleaned_text = re.sub("e", "ε", cleaned_text)
        cleaned_text = re.sub("f", "φ", cleaned_text)
        cleaned_text = re.sub("g", "γ", cleaned_text)
        cleaned_text = re.sub("h", "χ", cleaned_text)
        cleaned_text = re.sub("i", "ι", cleaned_text)
        cleaned_text = re.sub("k", "κ", cleaned_text)
        cleaned_text = re.sub("l", "λ", cleaned_text)
        cleaned_text = re.sub("m", "μ", cleaned_text)
        cleaned_text = re.sub("n", "ν", cleaned_text)
        cleaned_text = re.sub("o", "ο", cleaned_text)
        cleaned_text = re.sub("p", "π", cleaned_text)
        cleaned_text = re.sub("r", "ρ", cleaned_text)
        cleaned_text = re.sub("s", "σ", cleaned_text)
        cleaned_text = re.sub("t", "τ", cleaned_text)
        cleaned_text = re.sub("u", "υ", cleaned_text)
        cleaned_text = re.sub("v", "β", cleaned_text)
        cleaned_text = re.sub("w", "ω", cleaned_text)
        cleaned_text = re.sub("s", "σ", cleaned_text)
        cleaned_text = re.sub("y", "υ", cleaned_text)
        cleaned_text = re.sub("z", "ζ", cleaned_text)

    # Removing punctuation marks except --> %
    for punc in "!\"#$&'()*+,-./:;<=>?@[\\]^_`{|}~":
        cleaned_text = re.sub(f"\{punc}", " ", cleaned_text)

        # Removing multiple spaces
        cleaned_text = re.sub(r"\s+", " ", cleaned_text)

        cleaned_text = cleaned_text.strip()

        # Removing accents
        cleaned_text = accent_remover(cleaned_text)

        # Removing digits except patterns with 1%
        cleaned_text = re.sub(r"(?![0-9]+\s?\%)[0-9]", " ", cleaned_text)

        # Removing multiple spaces
        cleaned_text = re.sub(r"\s+", " ", cleaned_text)

    return cleaned_text


def abbreviation_creator(text: str) -> str:
    """
    Converts variations of certain phrases to their abbreviations.

    Args:
    ----
    text (str): Input text to be converted.

    Returns:
    -------
    str: Converted text with abbreviations.

    """
    # Substituting ενα τις 100, ενα στις 100, μια τις 100, μια στις 100, 1 τις εκατο, 1 στις εκατο, 1/100 and 0.01 to 1%
    cleaned_text = re.sub("εναςτιςεκατο", "1%", text)
    cleaned_text = re.sub(
        r"(ενα\s?τ[α-ω]+\s?εκατο)|(ενα\s?στ[α-ω]+\s?εκατο)|(μια\s?τ[α-ω]+\s?εκατο)|(μια\s?στ[α-ω]+\s?εκατο)|(ενα\s?τ[α-ω]+\s?100)|(ενα\s?στ[α-ω]+\s?100)|(μια\s?τ[α-ω]+\s?100)|(μια\s?στ[α-ω]+\s?100)|(1\s?τ[α-ω]+\s?100)|(1\s?στ[α-ω]+\s?100)|(1\s?τ[α-ω]+\s?100)|(1\s?στ[α-ω]+\s?100)|(1/100)|(0.01)|(0,01)",
        " 1% ",
        cleaned_text,
    )

    # Converting variations of χρυση αυγη to χα
    cleaned_text = re.sub(
        r"(χρυσ[αυγιτης|αυγιτες|\s?αυγη]+\s?)|(χρυσ[η|ες]+\s?αυγ[η|ες]+)",
        "χα",
        cleaned_text,
    )

    # Converting variations of ευρωπαικη ενωση to εε
    cleaned_text = re.sub(r"ευρωπαικ[η|ης]+\sενωσ[η|εις]+", "εε", cleaned_text)

    # Converting variations of ηνωμενες πολιτειες to ηπα
    cleaned_text = re.sub(
        r"(ηνωμενε[σ|ς]+\s?πολιτειε[σ|ς]+\s?((της)?\s?αμερικη[σ|ς]+)?)|(αμερικη)|(αμερικανοι)|(αμερικανακια)|(αμερικανακι)",
        "ηπα",
        cleaned_text,
    )

    # Converting variations of ηνωμενα αραβικα εμιρατα to ηαε
    cleaned_text = re.sub(r"(ηνωμενα)?\s*(αραβικα)?\s*εμιρατα", "ηαε", cleaned_text)

    # Converting variations of μη κυβερνητικες οργανωσεις to μκο
    cleaned_text = re.sub(
        r"(μη\s*κυβερνητικε[σ|ς]+\s*οργανωσει[σ|ς]+)|(μη\s*κυβερνητικη\s*οργανωση)",
        "μκο",
        cleaned_text,
    )

    # Removing multiple spaces
    cleaned_text = re.sub(r"\s+", " ", cleaned_text)

    return cleaned_text


def lemma_stem(text: str, word_normalization: str) -> str:
    """
    Returns a text in which every word is stemmed or lemmatized.

    Args:
    ----
    text (str): Input text to be stemmed or lemmatized.
    word_normalization (str): Normalization method, either "stem" or "lemma".

    Returns:
    -------
    str: Stemmed or lemmatized text.

    """
    # Stem or lemma
    if word_normalization == "stem":
        # Removing accents
        cleaned_text = text
        f = []

        # If token is in the abbreviation list, don't apply stemming
        for i in range(len(cleaned_text.split())):
            if cleaned_text.split()[i] in ["μκο", "ηπα", "χα", "ηαε", "εε", "1%"]:
                f.append(cleaned_text.split()[i])
                continue

            else:
                f.append(stemmer.stem(cleaned_text.split()[i].upper()).lower())

    elif word_normalization == "lemma":
        cleaned_text = text
        f = []

        # If token is in the abbreviation list, don't apply lemmatization
        for i in range(len(cleaned_text.split())):
            if cleaned_text.split()[i] in ["μκο", "ηπα", "χα", "ηαε", "εε"]:
                f.append(cleaned_text.split()[i])
                continue

            else:
                doc = nlp(cleaned_text.split()[i])
                for token in doc:
                    f.append(str(token.lemma_))

    else:
        return print(
            f"Please insert lemma or stem. Argument passed: {word_normalization}"
        )

    cleaned_text = f

    cleaned_text = " ".join(cleaned_text)

    # Removing multiple spaces
    cleaned_text = re.sub(r"\s+", " ", cleaned_text)

    return cleaned_text


def cleaner(text: str, stem_dict: Dict[str, str]) -> str:
    """
    Cleans the input text by removing unwanted characters, normalizing certain words,

    Args:
    ----
    text (str): Input text to be cleaned.
    stem_dict (Dict[str, str]): Dictionary for stemming or lemmatization.

    Returns:
    -------
    str: Cleaned text with unwanted characters removed and certain words normalized.

    """
    # Tokenize text
    cleaned_text = text.split()

    # Remove "´""
    cleaned_text = [re.sub(r"´", " ", text) for text in cleaned_text]

    # Converting variations of λαθρομεταναστης to λαθρο
    cleaned_text = [
        re.sub(
            r"(^λαθρ[α-ω]{,8}\s?)|(\s?λαθρ[α-ω]{,8}$)|(\s?λαθρ[α-ω]{,8}\s?)",
            " λαθρο ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting variations of χωρανε to _χωρανε
    cleaned_text = [
        re.sub(
            r"(\s?χωραει$)|(^χωραει\s?)|(\s?χωραει\s?)|(^χωρανε\s?)|(\s?χωρανε$)|(\s?χωρανε\s?)|(^χωρο\s?)|(\s?χωρο$)|(\s?χωρο\s?)|(^χωροι\s?)|(\s?χωροι$)|(\s?χωροι\s?)|(^χωρος\s?)|(\s?χωρος$)|(\s?χωρος\s?)|(^χωρου\s?)|(\s?χωρου$)|(\s?χωρου\s?)|(^χωρους\s?)|(\s?χωρους$)|(\s?χωρους\s?)",
            " _χωρανε ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting χρημα variations to χρημα
    cleaned_text = [
        re.sub(
            r"(χρημ[α-ω]{,8}$)|(^χρημ[α-ω]{,8}\s?)|(\s?χρημ[α-ω]{,8}\s?)",
            " χρηματα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting ανθρωπια variations to _ανθρωπια
    cleaned_text = [
        re.sub(r"(^ανθρωπια\s?)|(\s?ανθρωπια$)|(\s?ανθρωπια\s?)", " _ανθρωπια ", text)
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting κανονας variations to κανονας
    cleaned_text = [
        re.sub(
            r"(^κανον[α-ω]{,8})|(\s?κανον[α-ω]{,8}$)|(\s?κανον[α-ω]{,8}\s?)",
            " κανονας ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting χωρα variations to χωρα
    cleaned_text = [
        re.sub(
            r"(^χωρα\s)|(\sχωρα$)|(\sχωρα\s)|(^χωρες\s)|(\sχωρες$)|(\sχωρες\s)|(^χωρας\s)|(\sχωρας$)|(\sχωρας\s)|(^χωρων\s)|(\sχωρων$)|(\sχωρων\s)",
            " χωρα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting πολυ variations to _πολυ
    cleaned_text = [
        re.sub(
            r"(^πολυ\s?)|(\s?πολυ$)|(\s?πολυ\s?)|(^πολλες\s?)|(\s?πολλες$)|(\s?πολλες\s?)|(^πολλα\s?)|(\s?πολλα$)|(\s?πολλα\s?)|(^πολλοι\s?)|(\s?πολλοι$)|(\s?πολλοι\s?)",
            " _πολυ ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting στιγμα variations to _στιγμα
    cleaned_text = [
        re.sub(
            r"(^στιγμα[α-ω]{,8}\s?)|(\s?στιγμα[α-ω]{,8}$)|(\s?στιγμα[α-ω]{,8}\s?)",
            " _στιγμα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting covid variations to covid
    cleaned_text = [
        re.sub(
            r"(^cοβ[α-ωa-z]{,3}\s?)|(\s?cοβ[α-ωa-z]{,3}$)|(\s?cοβ[α-ωa-z]{,3}\s?)",
            " covid ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove "¨"
    cleaned_text = [re.sub(r"¨", " ", text) for text in cleaned_text]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove "¨"
    cleaned_text = [re.sub(r"΄΄", " ", text) for text in cleaned_text]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove "«"
    cleaned_text = [re.sub(r"«", " ", text) for text in cleaned_text]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove "»"
    cleaned_text = [re.sub(r"»", " ", text) for text in cleaned_text]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγαθα variations to αγαθα
    cleaned_text = [
        re.sub(
            r"(^αγαθ[α-ω]{,2}\s?)|(\s?αγαθ[α-ω]{,2}$)|(\s?αγαθ[α-ω]{,2}\s?)",
            " αγαθα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγανακτηση variations to αγανακτηση
    cleaned_text = [
        re.sub(
            r"(^αγανακτ[α-ω]{,8}\s?)|(\s?αγανακτ[α-ω]{,8}$)|(\s?αγανακτ[α-ω]{,8}\s?)",
            " αγανακτηση ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove cατερινγκ variations
    cleaned_text = [
        re.sub(
            r"(^cατερινγ\s?)|(\s?cατερινγ$)|(\s?cατερινγ\s?)|(^cομ\s?)|(\s?cομ$)|(\s?cομ\s?)",
            " ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove all numbers except those refering to %
    cleaned_text = [
        re.sub(
            r"(^[0-9]{2,3}\s?%\s?)|(\s?[0-9]{2,3}\s?%$)|(\s?[0-9]{2,3}\s?%\s?)",
            " % ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγαπη variations to αγαπη
    cleaned_text = [
        re.sub(
            r"(^αγαπ[α-ω]{,8}\s?)|(\s?αγαπ[α-ω]{,8}$)|(\s?αγαπ[α-ω]{,8}\s?)",
            " αγαπη ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγγλια variations to αγγλια
    cleaned_text = [
        re.sub(
            r"(^αγγλ[α-ω]{,8}\s?)|(\s?αγγλ[α-ω]{,8}$)|(\s?αγγλ[α-ω]{,8}\s?)",
            " αγγλια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting εγκατελειψαν variations to εγκατελειψαν
    cleaned_text = [
        re.sub(
            r"(^αγκατελειψαν\s?)|(\s?αγκατελειψαν$)|(\s?αγκατελειψαν\s?)",
            " εγκατελειψαν ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγνοια variations to αγνοια
    cleaned_text = [
        re.sub(
            r"(^αγνο[α-ω]{2,8}\s?)|(\s?αγνο[α-ω]{2,8}$)|(\s?αγνο[α-ω]{2,8}\s?)",
            " αγνοια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγνωστο variations to αγνωστο
    cleaned_text = [
        re.sub(
            r"(^αγνωστ[α-ω]{1,8}\s?)|(\s?αγνωστ[α-ω]{1,8}$)|(\s?αγνωστ[α-ω]{1,8}\s?)",
            " αγνωστο ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγωνα variations to αγωνα
    cleaned_text = [
        re.sub(r"(^αγονα\s?)|(\s?αγονα$)|(\s?αγονα\s?)", " αγωνα ", text)
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγορα variations to αγορα
    cleaned_text = [
        re.sub(
            r"(^αγορ[α-ω]{1}ς )|( αγορ[α-ω]{1}ς$)|( αγορ[α-ω]{1}ς )", " αγορα ", text
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγροτικο variations to αγροτικο
    cleaned_text = [
        re.sub(
            r"(^αγρο[α-ω]{,8}\s?)|(\s?αγρο[α-ω]{,8}$)|(\s?αγρο[α-ω]{,8}\s?)",
            " αγροτικο ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αγωνες variations to αγωνα
    cleaned_text = [
        re.sub(
            r"(^αγωνες\s?)|(\s?αγωνες$)|(\s?αγωνες\s?)|(^αγωνιζεσαι\s?)|(\s?αγωνιζεσαι$)|(\s?αγωνιζεσαι\s?)|(^αγωνιζεται\s?)|(\s?αγωνιζεται$)|(\s?αγωνιζεται\s?)|(^αγωνιζομαστε\s?)|(\s?αγωνιζομαστε$)|(\s?αγωνιζομαστε\s?)|(^αγωνισθουν\s?)|(\s?αγωνισθουν$)|(\s?αγωνισθουν\s?)|(^αγωνιστηκε\s?)|(\s?αγωνιστηκε$)|(\s?αγωνιστηκε\s?)|(^αγωνιστουμε\s?)|(\s?αγωνιστουμε$)|(\s?αγωνιστουμε\s?)|(^αγωνιστουν\s?)|(\s?αγωνιστουν$)|(\s?αγωνιστουν\s?)|(^αγωνας\s?)|(\s?αγωνας$)|(\s?αγωνας\s?)",
            " αγωνα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδεια variations to αδεια
    cleaned_text = [
        re.sub(r"(^αδειας\s?)|(\s?αδειας$)|(\s?αδειας\s?)", " αδεια ", text)
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδελφικες variations to αδελφια
    cleaned_text = [
        re.sub(
            r"(^αδελφικες\s?)|(\s?αδελφικες$)|(\s?αδελφικες\s?)|(^αδελφους\s?)|(\s?αδελφους$)|(\s?αδελφους\s?)|(^αδελφο\s?)|(\s?αδελφο$)|(\s?αδελφο\s?)|(^αδερφες\s?)|(\s?αδερφες$)|(\s?αδερφες\s?)|(^αδερφια\s?)|(\s?αδερφια$)|(\s?αδερφια\s?)",
            " αδελφια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδιαβλητα variations to αδιαβλητα
    cleaned_text = [
        re.sub(
            r"(^αδιαβλητ[α-ω]{,3}\s?)|(\s?αδιαβλητ[α-ω]{,3}$)|(\s?αδιαβλητ[α-ω]{,3}\s?)",
            " αδιαβλητα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]
    cleaned_text = [
        re.sub(
            r"(^αδιαπραγματε[α-ω]{,8}\s?)|(\s?αδιαπραγματε[α-ω]{,8}$)|(\s?αδιαπραγματε[α-ω]{,8}\s?)",
            " αδιαπραγματευτο ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδιαφανεια variations to αδιαφανεια
    cleaned_text = [
        re.sub(
            r"(^αδιαφαν[α-ω]{,8}\s?)|(\s?αδιαφαν[α-ω]{,8}$)|(\s?αδιαφαν[α-ω]{,8}\s?)",
            " αδιαφανεια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδιαφορια variations to αδιαφορια
    cleaned_text = [
        re.sub(
            r"(^αδιαφορ[α-ω]{,8}\s?)|(\s?αδιαφορ[α-ω]{,8}$)|(\s?αδιαφορ[α-ω]{,8}\s?)",
            " αδιαφορια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδικο variations to αδικο
    cleaned_text = [
        re.sub(
            r"(^αδικ[α-ω]{,8}\s?)|(\s?αδικ[α-ω]{,8}\$)|(\s?αδικ[α-ω]{,8}\s?)",
            " αδικο ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδικο variations to αδικο
    cleaned_text = [
        re.sub(r"(^αδικοες\s?)|(\s?αδικοες$)|(\s?αδικοες\s?)", " αδικο ", text)
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδρανεια variations to αδρανεια
    cleaned_text = [
        re.sub(
            r"(^αδραν[α-ω]{,8}\s?)|(\s?αδραν[α-ω]{,8}$)|(\s?αδραν[α-ω]{,8}\s?)",
            " αδρανεια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδυναμια variations to αδυναμια
    cleaned_text = [
        re.sub(
            r"(^αδυναμ[α-ω]{,8}\s?)|(\s?αδυναμ[α-ω]{,8}$)|(\s?αδυναμ[α-ω]{,8}\s?)",
            " αδυναμια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αδυνατο variations to αδυνατο
    cleaned_text = [
        re.sub(
            r"(^αδυνατ[α-ω]{,8}\s?)|(\s?αδυνατ[α-ω]{,8}$)|(\s?αδυνατ[α-ω]{,8}\s?)",
            " αδυνατο ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting αηδια variations to αηδια
    cleaned_text = [
        re.sub(
            r"(^αηδ[α-ω]{,8}\s?)|(\s?αηδ[α-ω]{,8}$)|(\s?αηδ[α-ω]{,8}\s?)",
            " αηδια ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Converting ανθρωπινα variations to ανθρωπινα
    cleaned_text = [
        re.sub(
            r"(^αθρωπιν[α-ω]{,8}\s?)|(\s?αθρωπιν[α-ω]{,8}$)|(\s?αθρωπιν[α-ω]{,8}\s?)",
            " ανθρωπινα ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove typos
    cleaned_text = [
        re.sub(
            r"(^ιπχον\s?)|(\s?ιπχον$)|(\s?ιπχον\s?)|(^ισικαου\s?)|(\s?ισικαου$)|(\s?ισικαου\s?)",
            " ",
            text,
        )
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove typos
    cleaned_text = [
        re.sub(r"(^υουρ\s?)|(\s?υουρ$)|(\s?υουρ\s?)", " ", text)
        for text in cleaned_text
    ]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Remove multiple spaces
    cleaned_text = [re.sub(r"\s+", " ", text) for text in cleaned_text]

    # Remove left-over characters of length 1
    cleaned_text = [text for text in cleaned_text if len(text) > 1]

    # Apply stemming
    cleaned_text = [lemma_stem(text, "stem") for text in cleaned_text]

    fin = []

    # Apply stemming where it is possible
    for token in cleaned_text:
        try:
            fin.append(stem_dict[token][0])
        except:
            fin.append(token)

    return " ".join(fin).strip()


def topic_cleaner(text: str) -> str:
    """
    Cleans the input text by removing unwanted characters, normalizing certain words,

    Args:
    ----
    text (str): Input text to be cleaned.

    Returns:
    -------
    str: Cleaned text with unwanted characters removed and certain words normalized.

    """
    # Convert text to string
    text = str(text)

    # Convert ενα τις εκατο variations to ενα τις εκατο
    cleaned_text = re.sub(
        r"(1\s?%)|(ενα\s?τ[α-ω]+\s?εκατο)|(ενα\s?στ[α-ω]+\s?εκατο)|(μια\s?τ[α-ω]+\s?εκατο)|(μια\s?στ[α-ω]+\s?εκατο)|(ενα\s?τ[α-ω]+\s?100)|(ενα\s?στ[α-ω]+\s?100)|(μια\s?τ[α-ω]+\s?100)|(μια\s?στ[α-ω]+\s?100)|(1\s?τ[α-ω]+\s?100)|(1\s?στ[α-ω]+\s?100)|(1\s?τ[α-ω]+\s?100)|(1\s?στ[α-ω]+\s?100)|(1/100)|(0.01)|(0,01)",
        " ενα τις εκατο ",
        text,
    )

    # Convert πολυ variations to πολυ
    cleaned_text = re.sub(r"\s_πολυ\s", " πολυ ", cleaned_text)

    # Convert απολυτως variations to απολυτως
    cleaned_text = re.sub(r"\sα πολυ τως\s", " απολυτως ", cleaned_text)

    # Convert διαβιωσης variations to διαβιωσης
    cleaned_text = re.sub(r"\sδιαβιωσεις\s", " διαβιωσης ", cleaned_text)

    # Convert διαβιωση variations to διαβιωση
    cleaned_text = re.sub(r"\sδιαβιωσης\s", " διαβιωση ", cleaned_text)

    # Convert διαβισωσης variations to διαβιωσης
    cleaned_text = re.sub(r"\sδιαβιωση\s", " διαβιωσης ", cleaned_text)

    # Convert ελεγχομενη variations to ελεγχομενη
    cleaned_text = re.sub(r"\sελεγχεται\s", " ελεγχομενη ", cleaned_text)

    # Convert παιδι variations to παιδι
    cleaned_text = re.sub(r"\sπαιδια\s", " παιδι ", cleaned_text)

    # Convert ελεγχομενη variations to ελεγχομενη
    cleaned_text = re.sub(r"\sελεγχομενα\s", " ελεγχομενη ", cleaned_text)

    # Convert μορφωση variations to μορφωση
    cleaned_text = re.sub(r"\sμορφωσει\s", " μορφωση ", cleaned_text)

    # Convert διασφαλιζε variations to διασφαλιζε
    cleaned_text = re.sub(r"\sδιασφαλιζει\s", " διασφαλιζε ", cleaned_text)

    # Convert διασφαλιζε variations to διασφαλιζει
    cleaned_text = re.sub(r"\sδιασφαλιζε\s", " διασφαλιζει ", cleaned_text)

    # Convert εισβολεα variations to εισβολεα
    cleaned_text = re.sub(r"\sεισβολεας\s", " εισβολεα ", cleaned_text)

    # Convert εισβολεα variations to εισβολεας
    cleaned_text = re.sub(r"\sεισβολεα\s", " εισβολεας ", cleaned_text)

    # Convert νησι variations to νησι
    cleaned_text = re.sub(r"\sνησια\s", " νησι ", cleaned_text)

    # Convert νησι variations to νησια
    cleaned_text = re.sub(r"\sνησι\s", " νησια ", cleaned_text)

    # Convert ανθρωπινες variations to ανθρωπινες
    cleaned_text = re.sub(r"\sανθρωπινα\s", " ανθρωπινες ", cleaned_text)

    # Convert μουσουλμανο variations to μουσουλμανο
    cleaned_text = re.sub(r"\sμουσουλμανοι\s", " μουσουλμανο ", cleaned_text)

    # Convert μουσουλμανοι variations to μουσουλμανοι
    cleaned_text = re.sub(r"\sμουσουλμανο\s", " μουσουλμανοι ", cleaned_text)

    # Convert νομος variations to νομο
    cleaned_text = re.sub(r"\sνομος\s", " νομο ", cleaned_text)

    # Convert νομο variations to νομος
    cleaned_text = re.sub(r"\sνομο\s", " νομος ", cleaned_text)

    # Convert μορφωση variations to μορφωση
    cleaned_text = re.sub(r"\sμορφωσε\s", " μορφωση ", cleaned_text)

    # Convert περιθαλψη variations to περιθαλψη
    cleaned_text = re.sub(r"\sπεριθαλψει\s", " περιθαλψη ", cleaned_text)

    # Convert κανονα variations to κανονα
    cleaned_text = re.sub(r"\sκανονας\s", " κανονα ", cleaned_text)

    # Convert κανονα variations to κανονας
    cleaned_text = re.sub(r"\sκανονα\s", " κανονας ", cleaned_text)

    # Convert τηρηση variations to τηρηση
    cleaned_text = re.sub(r"\sτηρηθουν\s", " τηρηση ", cleaned_text)

    # Convert κλειστες variations to κλειστες
    cleaned_text = re.sub(r"\sα κλειστες\s", " κλειστες ", cleaned_text)

    # Convert εξοδο variations to εξοδο
    cleaned_text = re.sub(r"\sεξοδα\s", " εξοδο ", cleaned_text)

    # Convert προσωρινα variations to προσωρινα
    cleaned_text = re.sub(r"\sπροσωρινες\s", " προσωρινα ", cleaned_text)

    # Convert ποσοστο variations to %
    cleaned_text = re.sub(r"\sποσοστο\s", " % ", cleaned_text)

    # Convert κλειστες variations to κλειστες
    cleaned_text = re.sub(r"\sγικλειστες\s", " κλειστες ", cleaned_text)

    # Convert σηκωνει variations to σηκωνει
    cleaned_text = re.sub(r"\sσηκωσει\s", " σηκωνει ", cleaned_text)

    # Convert κλειστες variations to κλειστες
    cleaned_text = re.sub(r"\sμικλειστες\s", " κλειστες ", cleaned_text)

    # Convert απελαση variations to απελαση
    cleaned_text = re.sub(r"\sαπελασει\s", " απελαση ", cleaned_text)

    # Convert ενταξη variations to ενταξη
    cleaned_text = re.sub(r"\sεντασσει\s", " ενταξη ", cleaned_text)

    # Convert τηρηση variations to τηρηση
    cleaned_text = re.sub(r"\sτηρει\s", " τηρηση ", cleaned_text)

    # Convert ενσωματωση variations to ενσωματωση
    cleaned_text = re.sub(r"\sενσωματωθει\s", " ενσωματωση ", cleaned_text)

    # Convert εγκληματιες variations to εγκληματιες
    cleaned_text = re.sub(r"\sεγκληματιας\s", " εγκληματιες ", cleaned_text)

    # Convert βοηθεια variations to βοηθεια
    cleaned_text = re.sub(r"\sβοηθα\s", " βοηθεια ", cleaned_text)

    # Convert επιβαλλουν variations to επιβαλλουν
    cleaned_text = re.sub(r"\sεπιβαλλει\s", " επιβαλλουν ", cleaned_text)

    # Convert αναγνωρισμενοι variations to αναγνωρισμενοι
    cleaned_text = re.sub(r"\sαναγνωρισμενες\s", " αναγνωρισμενοι ", cleaned_text)

    # Tokenize text
    cleaned_text = cleaned_text.split()

    # Remove stopwords
    cleaned_text = [t for t in cleaned_text if t not in stop_words]

    # Connect tokens
    cleaned_text = " ".join(cleaned_text)

    # Remove multiple spaces
    cleaned_text = re.sub(r"\s{2,}", " ", cleaned_text)

    return cleaned_text


def topic_dictionary(dataframe: pd.DataFrame) -> Dict[str, str]:
    """
    Creates a dictionary with keywords as keys and topics as values.

    Args:
    ----
    dataframe (pd.DataFrame): DataFrame containing the keywords and their corresponding topics.

    Returns:
    -------
    Dict[str, str]: Dictionary with keywords as keys and topics as values.

    """
    # Store every column to a 1d numpy array
    Worthiness = dataframe.iloc[1:, 0].values.tolist()
    Humanitarian = dataframe.iloc[1:, 1].values.tolist()
    Economic = dataframe.iloc[1:, 2].values.tolist()
    Cultural = dataframe.iloc[1:, 3].values.tolist()
    Security = dataframe.iloc[1:, 4].values.tolist()
    Fairness = dataframe.iloc[1:, 5].values.tolist()
    Institutiοnal = dataframe.iloc[1:, 6].values.tolist()
    Assimilation = dataframe.iloc[1:, 7].values.tolist()
    Public = dataframe.iloc[1:, 8].values.tolist()

    # Replace underscore character with a space character if this term is not "nothing"
    Worthiness = [re.sub(r"\_", " ", term) for term in Worthiness if term != "nothing"]
    Humanitarian = [
        re.sub(r"\_", " ", term) for term in Humanitarian if term != "nothing"
    ]
    Economic = [re.sub(r"\_", " ", term) for term in Economic if term != "nothing"]
    Cultural = [re.sub(r"\_", " ", term) for term in Cultural if term != "nothing"]
    Security = [re.sub(r"\_", " ", term) for term in Security if term != "nothing"]
    Fairness = [re.sub(r"\_", " ", term) for term in Fairness if term != "nothing"]
    Institutiοnal = [
        re.sub(r"\_", " ", term) for term in Institutiοnal if term != "nothing"
    ]
    Assimilation = [
        re.sub(r"\_", " ", term) for term in Assimilation if term != "nothing"
    ]
    Public = [re.sub(r"\_", " ", term) for term in Public if term != "nothing"]

    # Initialize a dictionary
    dictionary = {}

    # Iterate through every column
    for term in Worthiness:
        # Iteratively update key-value pairs of the dictionary
        dictionary[f"{term}"] = "Identity Characteristics"

    for term in Humanitarian:
        dictionary[f"{term}"] = "Legal rationale"

    for term in Economic:
        dictionary[f"{term}"] = "Cultural/ Social  concerns"

    for term in Cultural:
        dictionary[f"{term}"] = "Public order concerns"

    for term in Security:
        dictionary[f"{term}"] = "Economic concerns"

    for term in Fairness:
        dictionary[f"{term}"] = "Humanitarian concerns"

    for term in Institutiοnal:
        dictionary[f"{term}"] = "Mobility concerns"

    for term in Assimilation:
        dictionary[f"{term}"] = "Trust in authorities"

    for term in Public:
        dictionary[f"{term}"] = "Fairness"

    return dictionary


def unigram_topic_matrix_creator(
    dataframe: pd.DataFrame, topic_dic: Dict[str, str]
) -> np.ndarray:
    """
    Returns a matrix with 0s and 1s, where the value 1 means that a respondent uses a unigram keyword, thus refers to a topic

    Args:
    ----
    dataframe (pd.DataFrame): Input DataFrame containing the cleaned text.
    topic_dic (Dict[str, str]): Dictionary where the keys are keywords and the values are the topics.

    Returns:
    -------
    np.ndarray: Matrix with shape (length of dataset, number of topics).

    """
    # Create 1d numpy array containing cleaned text
    text = dataframe.cleaned.values.tolist()

    # Initialize topic matrix with zeros
    matrix = np.zeros((len(text), 9))

    # Initialize topic dictionary
    dictionary = {
        "Identity Characteristics": 0,
        "Legal rationale": 1,
        "Cultural/ Social  concerns": 2,
        "Public order concerns": 3,
        "Economic concerns": 4,
        "Humanitarian concerns": 5,
        "Mobility concerns": 6,
        "Trust in authorities": 7,
        "Fairness": 8,
    }

    # Iterate through texts
    for row in range(matrix.shape[0]):
        # Tokenize text
        t = text[row].split()

        # For every term in the text
        for term in t:
            # Try to map it to a topic or multiple topics
            try:
                x = topic_dic[term]
                x = dictionary[x]
                matrix[row, x] = 1

                # Else do nothing
            except:
                pass

    return matrix


def bigram_topic_matrix_creator(
    dataframe: pd.DataFrame, topic_dic: Dict[str, str]
) -> np.ndarray:
    """
    Returns a matrix with 0s and 1s, where the value 1 means that a respondent uses a bigram keyword, thus refers to a topic

    Args:
    ----
    dataframe (pd.DataFrame): Input DataFrame containing the cleaned text.
    topic_dic (Dict[str, str]): Dictionary where the keys are keywords and the values are the topics.

    Returns:
    -------
    np.ndarray: Matrix with shape (length of dataset, number of topics).

    """
    # Create 1d numpy array containing cleaned text
    text = dataframe.cleaned.values.tolist()

    # Get terms from dictionary (meaning its keys)
    terms = list(topic_dic.keys())

    # Initialize topic matrix with zeros
    matrix = np.zeros((len(text), 9))

    # Initialize topic dictionary
    dictionary = {
        "Identity Characteristics": 0,
        "Legal rationale": 1,
        "Cultural/ Social  concerns": 2,
        "Public order concerns": 3,
        "Economic concerns": 4,
        "Humanitarian concerns": 5,
        "Mobility concerns": 6,
        "Trust in authorities": 7,
        "Fairness": 8,
    }

    # Iterate through texts
    for row in range(matrix.shape[0]):
        # Get text
        t = text[row]
        # Iterate through terms
        for term in terms:
            # Find all occurrences
            x = re.findall(term, t)

            # If the matched term has length > 1
            if len(x) > 0:
                # Update topic dictionary
                x = topic_dic[term]
                x = dictionary[x]
                matrix[row, x] = 1

            else:
                # Else, ignore it
                pass

    return matrix


def normalize_citizens_text(
    text_analysis: pd.DataFrame, normalization_type: str
) -> List[str]:
    """
    Cleans the input text by removing unwanted characters, normalizing certain words,

    Args:
    ----
    text_analysis (pd.DataFrame): Input DataFrame containing the text to be cleaned.
    normalization_type (str): Normalization type to be used, either "stem" for stemming or "lemma" for lemmatization.

    Returns:
    -------
    List[str]: List of cleaned text strings.

    """
    # Using regular expressions to clean the text

    # adding texts to a list
    citizens = text_analysis.cleaned.values.tolist()

    # creating a list for each text, thus a list of lists
    citizens = [text.split() for text in citizens]

    # lowercasing each text
    citizens = [text.lower() for t in citizens for text in t]

    # removing duplicates
    citizens = list(set(citizens))

    # removing --> ´
    citizens = [re.sub(r"´", " ", text) for text in citizens]

    # Substituting λαθρο variations with λαθρο
    citizens = [
        re.sub(
            r"(^λαθρ[α-ω]{,8}\s?)|(\s?λαθρ[α-ω]{,8}$)|(\s?λαθρ[α-ω]{,8}\s?)",
            " λαθρο ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting χωραει variations with _χωρανε
    citizens = [
        re.sub(
            r"(\s?χωραει$)|(^χωραει\s?)|(\s?χωραει\s?)|(^χωρανε\s?)|(\s?χωρανε$)|(\s?χωρανε\s?)|(^χωρο\s?)|(\s?χωρο$)|(\s?χωρο\s?)|(^χωροι\s?)|(\s?χωροι$)|(\s?χωροι\s?)|(^χωρος\s?)|(\s?χωρος$)|(\s?χωρος\s?)|(^χωρου\s?)|(\s?χωρου$)|(\s?χωρου\s?)|(^χωρους\s?)|(\s?χωρους$)|(\s?χωρους\s?)",
            " _χωρανε ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting χρημ variations with χρηματα
    citizens = [
        re.sub(
            r"(χρημ[α-ω]{,8}$)|(^χρημ[α-ω]{,8}\s?)|(\s?χρημ[α-ω]{,8}\s?)",
            " χρηματα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting ανθρωπια variations with _ανθρωπια
    citizens = [
        re.sub(r"(^ανθρωπια\s?)|(\s?ανθρωπια$)|(\s?ανθρωπια\s?)", " _ανθρωπια ", text)
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting κανον variations with κανονας
    citizens = [
        re.sub(
            r"(^κανον[α-ω]{,8})|(\s?κανον[α-ω]{,8}$)|(\s?κανον[α-ω]{,8}\s?)",
            " κανονας ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting χωρα variations χωρα
    citizens = [
        re.sub(
            r"(^χωρα\s)|(\sχωρα$)|(\sχωρα\s)|(^χωρες\s)|(\sχωρες$)|(\sχωρες\s)|(^χωρας\s)|(\sχωρας$)|(\sχωρας\s)|(^χωρων\s)|(\sχωρων$)|(\sχωρων\s)",
            " χωρα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting πολυ variations with _πολυ
    citizens = [
        re.sub(
            r"(^πολυ\s?)|(\s?πολυ$)|(\s?πολυ\s?)|(^πολλες\s?)|(\s?πολλες$)|(\s?πολλες\s?)|(^πολλα\s?)|(\s?πολλα$)|(\s?πολλα\s?)|(^πολλοι\s?)|(\s?πολλοι$)|(\s?πολλοι\s?)",
            " _πολυ ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting στιγμα variations with _στιγμα
    citizens = [
        re.sub(
            r"(^στιγμα[α-ω]{,8}\s?)|(\s?στιγμα[α-ω]{,8}$)|(\s?στιγμα[α-ω]{,8}\s?)",
            " _στιγμα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # Substituting covid variations with covid
    citizens = [
        re.sub(
            r"(^cοβ[α-ωa-z]{,3}\s?)|(\s?cοβ[α-ωa-z]{,3}$)|(\s?cοβ[α-ωa-z]{,3}\s?)",
            " covid ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing ¨
    citizens = [re.sub(r"¨", " ", text) for text in citizens]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing ΄΄
    citizens = [re.sub(r"΄΄", " ", text) for text in citizens]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # removing «
    citizens = [re.sub(r"«", " ", text) for text in citizens]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # removing »
    citizens = [re.sub(r"»", " ", text) for text in citizens]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting covid variations with covid
    citizens = [
        re.sub(
            r"(^αγαθ[α-ω]{,2}\s?)|(\s?αγαθ[α-ω]{,2}$)|(\s?αγαθ[α-ω]{,2}\s?)",
            " αγαθα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγανακτηση variations with αγανακτηση
    citizens = [
        re.sub(
            r"(^αγανακτ[α-ω]{,8}\s?)|(\s?αγανακτ[α-ω]{,8}$)|(\s?αγανακτ[α-ω]{,8}\s?)",
            " αγανακτηση ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Removing cατερινγ
    citizens = [
        re.sub(
            r"(^cατερινγ\s?)|(\s?cατερινγ$)|(\s?cατερινγ\s?)|(^cομ\s?)|(\s?cομ$)|(\s?cομ\s?)",
            " ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting number% variations with %
    citizens = [
        re.sub(
            r"(^[0-9]{2,3}\s?%\s?)|(\s?[0-9]{2,3}\s?%$)|(\s?[0-9]{2,3}\s?%\s?)",
            " % ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγαπη variations with αγαπη
    citizens = [
        re.sub(
            r"(^αγαπ[α-ω]{,8}\s?)|(\s?αγαπ[α-ω]{,8}$)|(\s?αγαπ[α-ω]{,8}\s?)",
            " αγαπη ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγγλια variations with αγγλια
    citizens = [
        re.sub(
            r"(^αγγλ[α-ω]{,8}\s?)|(\s?αγγλ[α-ω]{,8}$)|(\s?αγγλ[α-ω]{,8}\s?)",
            " αγγλια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting εγκατελειπω variations with εγκατελειψαν
    citizens = [
        re.sub(
            r"(^αγκατελειψαν\s?)|(\s?αγκατελειψαν$)|(\s?αγκατελειψαν\s?)",
            " εγκατελειψαν ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγνοια variations with αγνοια
    citizens = [
        re.sub(
            r"(^αγνο[α-ω]{2,8}\s?)|(\s?αγνο[α-ω]{2,8}$)|(\s?αγνο[α-ω]{2,8}\s?)",
            " αγνοια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγνωστο variations with αγνωστο
    citizens = [
        re.sub(
            r"(^αγνωστ[α-ω]{1,8}\s?)|(\s?αγνωστ[α-ω]{1,8}$)|(\s?αγνωστ[α-ω]{1,8}\s?)",
            " αγνωστο ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγωνα variations with αγωνα
    citizens = [
        re.sub(r"(^αγονα\s?)|(\s?αγονα$)|(\s?αγονα\s?)", " αγωνα ", text)
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγορα variations with αγορα
    citizens = [
        re.sub(
            r"(^αγορ[α-ω]{1}ς )|( αγορ[α-ω]{1}ς$)|( αγορ[α-ω]{1}ς )", " αγορα ", text
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγροτικο variations with αγροτικο
    citizens = [
        re.sub(
            r"(^αγρο[α-ω]{,8}\s?)|(\s?αγρο[α-ω]{,8}$)|(\s?αγρο[α-ω]{,8}\s?)",
            " αγροτικο ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αγωνα variations with αγωνα
    citizens = [
        re.sub(
            r"(^αγωνες\s?)|(\s?αγωνες$)|(\s?αγωνες\s?)|(^αγωνιζεσαι\s?)|(\s?αγωνιζεσαι$)|(\s?αγωνιζεσαι\s?)|(^αγωνιζεται\s?)|(\s?αγωνιζεται$)|(\s?αγωνιζεται\s?)|(^αγωνιζομαστε\s?)|(\s?αγωνιζομαστε$)|(\s?αγωνιζομαστε\s?)|(^αγωνισθουν\s?)|(\s?αγωνισθουν$)|(\s?αγωνισθουν\s?)|(^αγωνιστηκε\s?)|(\s?αγωνιστηκε$)|(\s?αγωνιστηκε\s?)|(^αγωνιστουμε\s?)|(\s?αγωνιστουμε$)|(\s?αγωνιστουμε\s?)|(^αγωνιστουν\s?)|(\s?αγωνιστουν$)|(\s?αγωνιστουν\s?)|(^αγωνας\s?)|(\s?αγωνας$)|(\s?αγωνας\s?)",
            " αγωνα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδεια variations with αδεια
    citizens = [
        re.sub(r"(^αδειας\s?)|(\s?αδειας$)|(\s?αδειας\s?)", " αδεια ", text)
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδελφια variations with αδελφια
    citizens = [
        re.sub(
            r"(^αδελφικες\s?)|(\s?αδελφικες$)|(\s?αδελφικες\s?)|(^αδελφους\s?)|(\s?αδελφους$)|(\s?αδελφους\s?)|(^αδελφο\s?)|(\s?αδελφο$)|(\s?αδελφο\s?)|(^αδερφες\s?)|(\s?αδερφες$)|(\s?αδερφες\s?)|(^αδερφια\s?)|(\s?αδερφια$)|(\s?αδερφια\s?)",
            " αδελφια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδιαβλητα variations with αδιαβλητα
    citizens = [
        re.sub(
            r"(^αδιαβλητ[α-ω]{,3}\s?)|(\s?αδιαβλητ[α-ω]{,3}$)|(\s?αδιαβλητ[α-ω]{,3}\s?)",
            " αδιαβλητα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδιαπραγματευτο variations with αδιαπραγματευτο
    citizens = [
        re.sub(
            r"(^αδιαπραγματε[α-ω]{,8}\s?)|(\s?αδιαπραγματε[α-ω]{,8}$)|(\s?αδιαπραγματε[α-ω]{,8}\s?)",
            " αδιαπραγματευτο ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδιαφανεια variations with αδιαφανεια
    citizens = [
        re.sub(
            r"(^αδιαφαν[α-ω]{,8}\s?)|(\s?αδιαφαν[α-ω]{,8}$)|(\s?αδιαφαν[α-ω]{,8}\s?)",
            " αδιαφανεια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδιαφορια variations with αδιαφορια
    citizens = [
        re.sub(
            r"(^αδιαφορ[α-ω]{,8}\s?)|(\s?αδιαφορ[α-ω]{,8}$)|(\s?αδιαφορ[α-ω]{,8}\s?)",
            " αδιαφορια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδικο variations with αδικο
    citizens = [
        re.sub(
            r"(^αδικ[α-ω]{,8}\s?)|(\s?αδικ[α-ω]{,8}\$)|(\s?αδικ[α-ω]{,8}\s?)",
            " αδικο ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδικο variations with αδικο
    citizens = [
        re.sub(r"(^αδικοες\s?)|(\s?αδικοες$)|(\s?αδικοες\s?)", " αδικο ", text)
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδρανεια variations with αδρανεια
    citizens = [
        re.sub(
            r"(^αδραν[α-ω]{,8}\s?)|(\s?αδραν[α-ω]{,8}$)|(\s?αδραν[α-ω]{,8}\s?)",
            " αδρανεια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδυναμια variations with αδυναμια
    citizens = [
        re.sub(
            r"(^αδυναμ[α-ω]{,8}\s?)|(\s?αδυναμ[α-ω]{,8}$)|(\s?αδυναμ[α-ω]{,8}\s?)",
            " αδυναμια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αδυνατο variations with αδυνατο
    citizens = [
        re.sub(
            r"(^αδυνατ[α-ω]{,8}\s?)|(\s?αδυνατ[α-ω]{,8}$)|(\s?αδυνατ[α-ω]{,8}\s?)",
            " αδυνατο ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting αηδια variations with αηδια
    citizens = [
        re.sub(
            r"(^αηδ[α-ω]{,8}\s?)|(\s?αηδ[α-ω]{,8}$)|(\s?αηδ[α-ω]{,8}\s?)",
            " αηδια ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Substituting ανθρωπινα variations with ανθρωπινα
    citizens = [
        re.sub(
            r"(^αθρωπιν[α-ω]{,8}\s?)|(\s?αθρωπιν[α-ω]{,8}$)|(\s?αθρωπιν[α-ω]{,8}\s?)",
            " ανθρωπινα ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Removing ιπχον variations
    citizens = [
        re.sub(
            r"(^ιπχον\s?)|(\s?ιπχον$)|(\s?ιπχον\s?)|(^ισικαου\s?)|(\s?ισικαου$)|(\s?ισικαου\s?)",
            " ",
            text,
        )
        for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # Removing υουρ variations
    citizens = [
        re.sub(r"(^υουρ\s?)|(\s?υουρ$)|(\s?υουρ\s?)", " ", text) for text in citizens
    ]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # removing double spaces
    citizens = [re.sub(r"\s+", " ", text) for text in citizens]

    # removing strings of length 1
    citizens = [text for text in citizens if len(text) > 1]

    # removing duplicates
    citizens = list(set(citizens))

    # stemming the texts
    citizens = [(text, lemma_stem(text, normalization_type)) for text in citizens]

    # sorting the text
    citizens.sort()

    return citizens


def normalize_councilors_text(
    text_analysis: pd.DataFrame, normalization_type: str
) -> List[str]:
    """
    Cleans the input text by removing unwanted characters, normalizing certain words,

    Args:
    ----
    text_analysis (pd.DataFrame): Input DataFrame containing the text to be cleaned.
    normalization_type (str): Normalization type to be used, either "stem" for stemming or "lemma" for lemmatization.

    Returns:
    -------
    List[str]: List of cleaned text strings.

    """
    # Similar as for Citizens (above), but for corpus 2 (councilors)
    councilors = text_analysis.cleaned.values.tolist()
    councilors = [text.split() for text in councilors]
    councilors = [text.lower() for t in councilors for text in t]
    councilors = list(set(councilors))
    councilors = [re.sub(r"´", " ", text) for text in councilors]
    councilors = [
        re.sub(
            r"(^λαθρ[α-ω]{,8}\s?)|(\s?λαθρ[α-ω]{,8}$)|(\s?λαθρ[α-ω]{,8}\s?)",
            " λαθρο ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(\s?χωραει$)|(^χωραει\s?)|(\s?χωραει\s?)|(^χωρανε\s?)|(\s?χωρανε$)|(\s?χωρανε\s?)|(^χωρο\s?)|(\s?χωρο$)|(\s?χωρο\s?)|(^χωροι\s?)|(\s?χωροι$)|(\s?χωροι\s?)|(^χωρος\s?)|(\s?χωρος$)|(\s?χωρος\s?)|(^χωρου\s?)|(\s?χωρου$)|(\s?χωρου\s?)|(^χωρους\s?)|(\s?χωρους$)|(\s?χωρους\s?)",
            " _χωρανε ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(χρημ[α-ω]{,8}$)|(^χρημ[α-ω]{,8}\s?)|(\s?χρημ[α-ω]{,8}\s?)",
            " χρηματα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(r"(^ανθρωπια\s?)|(\s?ανθρωπια$)|(\s?ανθρωπια\s?)", " _ανθρωπια ", text)
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(^κανον[α-ω]{,8})|(\s?κανον[α-ω]{,8}$)|(\s?κανον[α-ω]{,8}\s?)",
            " κανονας ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(^χωρα\s)|(\sχωρα$)|(\sχωρα\s)|(^χωρες\s)|(\sχωρες$)|(\sχωρες\s)|(^χωρας\s)|(\sχωρας$)|(\sχωρας\s)|(^χωρων\s)|(\sχωρων$)|(\sχωρων\s)",
            " χωρα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(^πολυ\s?)|(\s?πολυ$)|(\s?πολυ\s?)|(^πολλες\s?)|(\s?πολλες$)|(\s?πολλες\s?)|(^πολλα\s?)|(\s?πολλα$)|(\s?πολλα\s?)|(^πολλοι\s?)|(\s?πολλοι$)|(\s?πολλοι\s?)",
            " _πολυ ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(^στιγμα[α-ω]{,8}\s?)|(\s?στιγμα[α-ω]{,8}$)|(\s?στιγμα[α-ω]{,8}\s?)",
            " _στιγμα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [
        re.sub(
            r"(^cοβ[α-ωa-z]{,3}\s?)|(\s?cοβ[α-ωa-z]{,3}$)|(\s?cοβ[α-ωa-z]{,3}\s?)",
            " covid ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [re.sub(r"¨", " ", text) for text in councilors]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = [re.sub(r"΄΄", " ", text) for text in councilors]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [re.sub(r"«", " ", text) for text in councilors]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [re.sub(r"»", " ", text) for text in councilors]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγαθ[α-ω]{,2}\s?)|(\s?αγαθ[α-ω]{,2}$)|(\s?αγαθ[α-ω]{,2}\s?)",
            " αγαθα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγανακτ[α-ω]{,8}\s?)|(\s?αγανακτ[α-ω]{,8}$)|(\s?αγανακτ[α-ω]{,8}\s?)",
            " αγανακτηση ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^cατερινγ\s?)|(\s?cατερινγ$)|(\s?cατερινγ\s?)|(^cομ\s?)|(\s?cομ$)|(\s?cομ\s?)",
            " ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^[0-9]{2,3}\s?%\s?)|(\s?[0-9]{2,3}\s?%$)|(\s?[0-9]{2,3}\s?%\s?)",
            " % ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγαπ[α-ω]{,8}\s?)|(\s?αγαπ[α-ω]{,8}$)|(\s?αγαπ[α-ω]{,8}\s?)",
            " αγαπη ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγγλ[α-ω]{,8}\s?)|(\s?αγγλ[α-ω]{,8}$)|(\s?αγγλ[α-ω]{,8}\s?)",
            " αγγλια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγκατελειψαν\s?)|(\s?αγκατελειψαν$)|(\s?αγκατελειψαν\s?)",
            " εγκατελειψαν ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγνο[α-ω]{2,8}\s?)|(\s?αγνο[α-ω]{2,8}$)|(\s?αγνο[α-ω]{2,8}\s?)",
            " αγνοια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγνωστ[α-ω]{1,8}\s?)|(\s?αγνωστ[α-ω]{1,8}$)|(\s?αγνωστ[α-ω]{1,8}\s?)",
            " αγνωστο ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(r"(^αγονα\s?)|(\s?αγονα$)|(\s?αγονα\s?)", " αγωνα ", text)
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγορ[α-ω]{1}ς )|( αγορ[α-ω]{1}ς$)|( αγορ[α-ω]{1}ς )", " αγορα ", text
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγρο[α-ω]{,8}\s?)|(\s?αγρο[α-ω]{,8}$)|(\s?αγρο[α-ω]{,8}\s?)",
            " αγροτικο ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αγωνες\s?)|(\s?αγωνες$)|(\s?αγωνες\s?)|(^αγωνιζεσαι\s?)|(\s?αγωνιζεσαι$)|(\s?αγωνιζεσαι\s?)|(^αγωνιζεται\s?)|(\s?αγωνιζεται$)|(\s?αγωνιζεται\s?)|(^αγωνιζομαστε\s?)|(\s?αγωνιζομαστε$)|(\s?αγωνιζομαστε\s?)|(^αγωνισθουν\s?)|(\s?αγωνισθουν$)|(\s?αγωνισθουν\s?)|(^αγωνιστηκε\s?)|(\s?αγωνιστηκε$)|(\s?αγωνιστηκε\s?)|(^αγωνιστουμε\s?)|(\s?αγωνιστουμε$)|(\s?αγωνιστουμε\s?)|(^αγωνιστουν\s?)|(\s?αγωνιστουν$)|(\s?αγωνιστουν\s?)|(^αγωνας\s?)|(\s?αγωνας$)|(\s?αγωνας\s?)",
            " αγωνα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(r"(^αδειας\s?)|(\s?αδειας$)|(\s?αδειας\s?)", " αδεια ", text)
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδελφικες\s?)|(\s?αδελφικες$)|(\s?αδελφικες\s?)|(^αδελφους\s?)|(\s?αδελφους$)|(\s?αδελφους\s?)|(^αδελφο\s?)|(\s?αδελφο$)|(\s?αδελφο\s?)|(^αδερφες\s?)|(\s?αδερφες$)|(\s?αδερφες\s?)|(^αδερφια\s?)|(\s?αδερφια$)|(\s?αδερφια\s?)",
            " αδελφια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδιαβλητ[α-ω]{,3}\s?)|(\s?αδιαβλητ[α-ω]{,3}$)|(\s?αδιαβλητ[α-ω]{,3}\s?)",
            " αδιαβλητα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδιαπραγματε[α-ω]{,8}\s?)|(\s?αδιαπραγματε[α-ω]{,8}$)|(\s?αδιαπραγματε[α-ω]{,8}\s?)",
            " αδιαπραγματευτο ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδιαφαν[α-ω]{,8}\s?)|(\s?αδιαφαν[α-ω]{,8}$)|(\s?αδιαφαν[α-ω]{,8}\s?)",
            " αδιαφανεια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδιαφορ[α-ω]{,8}\s?)|(\s?αδιαφορ[α-ω]{,8}$)|(\s?αδιαφορ[α-ω]{,8}\s?)",
            " αδιαφορια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδικ[α-ω]{,8}\s?)|(\s?αδικ[α-ω]{,8}\$)|(\s?αδικ[α-ω]{,8}\s?)",
            " αδικο ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(r"(^αδικοες\s?)|(\s?αδικοες$)|(\s?αδικοες\s?)", " αδικο ", text)
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδραν[α-ω]{,8}\s?)|(\s?αδραν[α-ω]{,8}$)|(\s?αδραν[α-ω]{,8}\s?)",
            " αδρανεια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδυναμ[α-ω]{,8}\s?)|(\s?αδυναμ[α-ω]{,8}$)|(\s?αδυναμ[α-ω]{,8}\s?)",
            " αδυναμια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αδυνατ[α-ω]{,8}\s?)|(\s?αδυνατ[α-ω]{,8}$)|(\s?αδυνατ[α-ω]{,8}\s?)",
            " αδυνατο ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αηδ[α-ω]{,8}\s?)|(\s?αηδ[α-ω]{,8}$)|(\s?αηδ[α-ω]{,8}\s?)",
            " αηδια ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^αθρωπιν[α-ω]{,8}\s?)|(\s?αθρωπιν[α-ω]{,8}$)|(\s?αθρωπιν[α-ω]{,8}\s?)",
            " ανθρωπινα ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(
            r"(^ιπχον\s?)|(\s?ιπχον$)|(\s?ιπχον\s?)|(^ισικαου\s?)|(\s?ισικαου$)|(\s?ισικαου\s?)",
            " ",
            text,
        )
        for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [
        re.sub(r"(^υουρ\s?)|(\s?υουρ$)|(\s?υουρ\s?)", " ", text) for text in councilors
    ]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [re.sub(r"\s+", " ", text) for text in councilors]
    councilors = [text for text in councilors if len(text) > 1]
    councilors = list(set(councilors))
    councilors = [(text, lemma_stem(text, normalization_type)) for text in councilors]
    councilors.sort()

    return councilors


def unify_citizens_councilors_texts(
    citizens_df: pd.DataFrame, councilors_df: pd.DataFrame
) -> Tuple[Dict[str, List[str]], Dict[str, List[str]]]:
    """
    Unify the citizens and councilors texts into dictionaries with stemmed words as keys and their original forms as values.

    Args:
    ----
    citizens_df (pd.DataFrame): DataFrame containing citizens text data.
    councilors_df (pd.DataFrame): DataFrame containing councilors text data.

    Returns:
    -------
    Tuple[Dict[str, List[str]], Dict[str, List[str]]]: Dictionaries with stemmed words as keys and their original forms as values for citizens and councilors.

    """
    # Create citizens and councilors lists
    citizens = normalize_citizens_text(
        text_analysis=citizens_df, normalization_type=normalization_type
    )
    councilors = normalize_councilors_text(
        text_analysis=councilors_df, normalization_type=normalization_type
    )

    # Creating a list with the stemmed words
    distinct_keys_1 = list(set([text[1] for text in citizens]))
    stem_dict_1 = {}

    # Iterating both on the stemmed words and the corpuses in order to substitute each word with its stem
    for i in range(len(distinct_keys_1)):
        c = []
        for j in range(len(citizens)):
            if citizens[j][1] == distinct_keys_1[i]:
                c.append(citizens[j][0])

        stem_dict_1[f"{distinct_keys_1[i]}"] = c
        c = []

    # The same as above
    distinct_keys_2 = list(set([text[1] for text in councilors]))
    stem_dict_2 = {}

    for i in range(len(distinct_keys_2)):
        c = []
        for j in range(len(councilors)):
            if councilors[j][1] == distinct_keys_2[i]:
                c.append(councilors[j][0])

        stem_dict_2[f"{distinct_keys_2[i]}"] = c

        c = []

    return stem_dict_1, stem_dict_2


def normalize_text_for_topic_analysis(
    text_analysis: pd.DataFrame,
    councilors_spelled: pd.DataFrame,
    stem_dict_1: Dict[str, List[str]],
    stem_dict_2: Dict[str, List[str]],
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """
    Normalize the text for topic analysis by applying various cleaning and normalization steps.
    This includes removing unwanted characters, normalizing certain words, and stemming.

    Args:
    ----
    text_analysis (pd.DataFrame): Citizens text data.
    councilors_spelled (pd.DataFrame): Councilors text data.
    stem_dict_1 (Dict[str, List[str]]): Dictionary with stemmed words as keys and their original forms as values for citizens.
    stem_dict_2 (Dict[str, List[str]]): Dictionary with stemmed words as keys and their original forms as values for councilors.

    Returns:
    -------
    Tuple[pd.DataFrame, pd.DataFrame]: Normalized DataFrames for citizens and councilors for topic analysis.

    """
    # Applying the cleaning function to the responses
    text_analysis["cleaned"] = text_analysis.cleaned.apply(
        lambda x: cleaner(x, stem_dict_1)
    )
    councilors_spelled["cleaned"] = councilors_spelled.cleaned.apply(
        lambda x: cleaner(x, stem_dict_2)
    )

    # Substituting χωρανε variations with χωρανε
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^_χωρανε\s?)|(\s?_χωρανε$)|(\s?_χωρανε\s?)", " χωρανε ", x)
    )
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^_χωρανε\s?)|(\s?_χωρανε$)|(\s?_χωρανε\s?)", " χωρανε ", x)
    )

    # Substituting ποσοστα variations with %
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^ποσοστα\s)|(\sποσοστα$)|(\sποσοστα\s)", " % ", x)
    )

    # Substituting ποσοστα variations with %
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^ποσοστο\s)|(\sποσοστο$)|(\sποσοστο\s)", " % ", x)
    )

    # Substituting στιγμα variations with στιγμα
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^_στιγμα\s)|(\s_στιγμα$)|(\s_στιγμα\s)", " στιγμα ", x)
    )

    # Substituting στιγμα variations with στιγμα
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^_στιγμα\s)|(\s_στιγμα$)|(\s_στιγμα\s)", " στιγμα ", x)
    )

    # Substituting τοπικα variations with τοπικη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^τοπικα\s)|(\sτοπικα$)|(\sτοπικα\s)", " τοπικη ", x)
    )

    # Substituting double spaces variations with space
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Substituting double spaces variations with space
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Substituting μεταναστε variations with μεταναστε
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^μεταναστες)|(μεταναστες$)|(μεταναστες)", "μεταναστε", x)
    )

    # Substituting μεταναστες variations with μεταναστες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^μεταναστε)|(μεταναστε$)|(μεταναστε)", "μεταναστες", x)
    )

    # Substituting μεταναστες variations with μεταναστες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^μεταναστες)|(μεταναστες$)|(μεταναστες)", "μεταναστε", x)
    )

    # Substituting μεταναστες variations with μεταναστες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^μεταναστε)|(μεταναστε$)|(μεταναστε)", "μεταναστες", x)
    )

    # Substituting δημος variations with δημ
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^δημος)|(δημος$)|(δημος)", "δημ", x)
    )

    # Substituting δημ variations with δημος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^δημ)|(δημ$)|(δημ)", "δημος", x)
    )

    # Substituting δημ variations with δημος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^δημος)|(δημος$)|(δημος)", "δημ", x)
    )

    # Substituting δημ variations with δημος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^δημ)|(δημ$)|(δημ)", "δημος", x)
    )

    # Substituting προσφυγας variations with προσφυγα
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^προσφυγας)|(προσφυγας$)|(προσφυγας)", "προσφυγα", x)
    )

    # Substituting προσφυγα variations with προσφυγας
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^προσφυγα)|(προσφυγα$)|(προσφυγα)", "προσφυγας", x)
    )

    # Substituting προσφυγα variations with προσφυγας
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^προσφυγας)|(προσφυγας$)|(προσφυγας)", "προσφυγα", x)
    )

    # Substituting προσφυγα variations with προσφυγας
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^προσφυγα)|(προσφυγα$)|(προσφυγα)", "προσφυγας", x)
    )

    # Substituting λαθρο variations with λαθρο
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^λαθρ[α-ω]{1,8}\s?)|(\s?λαθρ[α-ω]{1,8}$)|(\s?λαθρ[α-ω]{1,8}\s?)",
            " λαθρο ",
            x,
        )
    )

    # Substituting λαθρο variations with λαθρο
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^λαθρ[α-ω]{1,8}\s?)|(\s?λαθρ[α-ω]{1,8}$)|(\s?λαθρ[α-ω]{1,8}\s?)",
            " λαθρο ",
            x,
        )
    )

    # Substituting μεταναστες variations with μεταναστες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^μεταναστ[α-ω]{1,8}\s?)|(\s?μεταναστ[α-ω]{1,8}$)|(\s?μεταναστ[α-ω]{1,8}\s?)",
            " μεταναστες ",
            x,
        )
    )

    # Substituting μεταναστες variations with μεταναστες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^μεταναστ[α-ω]{1,8}\s?)|(\s?μεταναστ[α-ω]{1,8}$)|(\s?μεταναστ[α-ω]{1,8}\s?)",
            " μεταναστες ",
            x,
        )
    )

    # Substituting προσφυγας variations with προσφυγας
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^προσφυγ[α-ω]{1,8}\s?)|(\s?προσφυγ[α-ω]{1,8}$)|(\s?προσφυγ[α-ω]{1,8}\s?)",
            " προσφυγας ",
            x,
        )
    )

    # Substituting προσφυγας variations with προσφυγας
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^προσφυγ[α-ω]{1,8}\s?)|(\s?προσφυγ[α-ω]{1,8}$)|(\s?προσφυγ[α-ω]{1,8}\s?)",
            " προσφυγας ",
            x,
        )
    )

    # Substituting δημος variations with δημος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^δημο[α-ω]{1,9}\s?)|(\s?δημο[α-ω]{1,9}$)|(\s?δημο[α-ω]{1,9}\s?)",
            " δημος ",
            x,
        )
    )

    # Substituting δημος variations with δημος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^δημο[α-ω]{1,9}\s?)|(\s?δημο[α-ω]{1,9}$)|(\s?δημο[α-ω]{1,9}\s?)",
            " δημος ",
            x,
        )
    )

    # Substituting οικονομικοι variations with οικονομικοι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^οικονομ[α-ω]{,8}\s?)|(\s?οικονομ[α-ω]{,8}$)|(\s?οικονομ[α-ω]{,8}\s?)",
            " οικονομικοι ",
            x,
        )
    )

    # Substituting οικονομικοι variations with οικονομικοι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^οικονομ[α-ω]{,8}\s?)|(\s?οικονομ[α-ω]{,8}$)|(\s?οικονομ[α-ω]{,8}\s?)",
            " οικονομικοι ",
            x,
        )
    )

    # Substituting κλειστες variations with κλειστες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^κλειστ[α-ω]{,8}\s?)|(\s?κλειστ[α-ω]{,8}$)|(\s?κλειστ[α-ω]{,8}\s?)",
            " κλειστες ",
            x,
        )
    )

    # Substituting κλειστες variations with κλειστες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^κλειστ[α-ω]{,8}\s?)|(\s?κλειστ[α-ω]{,8}$)|(\s?κλειστ[α-ω]{,8}\s?)",
            " κλειστες ",
            x,
        )
    )

    # Removing double spaces
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Removing double spaces
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Substituting εκπαιδευση variations with εκπαιδευση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^εκπαιδ[α-ω]{,8}\s?)|(\sεκπαιδ[α-ω]{,8}$)|(\sεκπαιδ[α-ω]{,8}\s?)",
            " εκπαιδευση ",
            x,
        )
    )

    # Substituting εκπαιδευση variations with εκπαιδευση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^εκπαιδ[α-ω]{,8}\s?)|(\s?εκπαιδ[α-ω]{,8}$)|(\s?εκπαιδ[α-ω]{,8}\s?)",
            " εκπαιδευση ",
            x,
        )
    )

    # Substituting μεγαλωνουν variations with μεγαλωνουν
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^μεγαλω[α-ω]{,8}\s)|(\sμεγαλω[α-ω]{,8}$)|(\sμεγαλω[α-ω]{,8}\s)",
            " μεγαλωνουν ",
            x,
        )
    )

    # Substituting μεγαλωνουν variations with μεγαλωνουν
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^μεγαλω[α-ω]{,8}\s)|(\sμεγαλω[α-ω]{,8}$)|(\sμεγαλω[α-ω]{,8}\s)",
            " μεγαλωνουν ",
            x,
        )
    )

    # Substituting ενσωματωση variations with ενσωματωση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ενσωματωσ[α-ω]{,8}\s)|(\sενσωματωσ[α-ω]{,8}$)|(\sενσωματωσ[α-ω]{,8}\s)",
            " ενσωματωση ",
            x,
        )
    )

    # Substituting ενσωματωση variations with ενσωματωση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ενσωματωσ[α-ω]{,8}\s)|(\sενσωματωσ[α-ω]{,8}$)|(\sενσωματωσ[α-ω]{,8}\s)",
            " ενσωματωση ",
            x,
        )
    )

    # Substituting ασυλο variations with ασυλο
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ασυλ[α-ω]{,8}\s)|(\sασυλ[α-ω]{,8}$)|(\sασυλ[α-ω]{,8}\s)", " ασυλο ", x
        )
    )

    # Substituting ασυλο variations with ασυλο
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ασυλ[α-ω]{,8}\s)|(\sασυλ[α-ω]{,8}$)|(\sασυλ[α-ω]{,8}\s)", " ασυλο ", x
        )
    )

    # Substituting διαβιωση variations with διαβιωση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^διαβιω[α-ω]{,8}\s)|(\sδιαβιω[α-ω]{,8}$)|(\sδιαβιω[α-ω]{,8}\s)",
            " διαβιωση ",
            x,
        )
    )

    # Substituting διαβιωση variations with διαβιωση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^διαβιω[α-ω]{,8}\s)|(\sδιαβιω[α-ω]{,8}$)|(\sδιαβιω[α-ω]{,8}\s)",
            " διαβιωση ",
            x,
        )
    )

    # Substituting κατοικια variations with κατοικια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^κατοικ[α-ω]{,8}\s)|(\sκατοικ[α-ω]{,8}$)|(\sκατοικ[α-ω]{,8}\s)",
            " κατοικια ",
            x,
        )
    )

    # Substituting κατοικια variations with κατοικια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^κατοικ[α-ω]{,8}\s)|(\sκατοικ[α-ω]{,8}$)|(\sκατοικ[α-ω]{,8}\s)",
            " κατοικια ",
            x,
        )
    )

    # Substituting οικογενεια variations with οικογενεια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^οικογεν[α-ω]{,8}\s)|(\sοικογεν[α-ω]{,8}$)|(\sοικογεν[α-ω]{,8}\s)",
            " οικογενεια ",
            x,
        )
    )

    # Substituting οικογενεια variations with οικογενεια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^οικογεν[α-ω]{,8}\s)|(\sοικογεν[α-ω]{,8}$)|(\sοικογεν[α-ω]{,8}\s)",
            " οικογενεια ",
            x,
        )
    )

    # Substituting αντισταθμιστικα variations with αντισταθμιστικα
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^αντισταθμιστηκα[α-ω]{,8}\s)|(\sαντισταθμιστηκα[α-ω]{,8}$)|(\sαντισταθμιστηκα[α-ω]{,8}\s)",
            " αντισταθμιστικα ",
            x,
        )
    )

    # Substituting ενταξη variations with ενταξη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ενταχ[α-ω]{,8}\s)|(\sενταχ[α-ω]{,8}$)|(\sενταχ[α-ω]{,8}\s)",
            " ενταξη ",
            x,
        )
    )

    # Substituting ενταξη variations with ενταξη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ενταχ[α-ω]{,8}\s)|(\sενταχ[α-ω]{,8}$)|(\sενταχ[α-ω]{,8}\s)",
            " ενταξη ",
            x,
        )
    )

    # Substituting πολιτισμος variations with πολιτισμος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^πολιτισμ[α-ω]{,8}\s)|(\sπολιτισμ[α-ω]{,8}$)|(\sπολιτισμ[α-ω]{,8}\s)",
            " πολιτισμος ",
            x,
        )
    )

    # Substituting πολιτισμος variations with πολιτισμος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^πολιτισμ[α-ω]{,8}\s)|(\sπολιτισμ[α-ω]{,8}$)|(\sπολιτισμ[α-ω]{,8}\s)",
            " πολιτισμος ",
            x,
        )
    )

    # Substituting απελαση variations with απελαση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^απελασ[α-ω]{,8}\s)|(\sαπελασ[α-ω]{,8}$)|(\sαπελασ[α-ω]{,8}\s)",
            " απελαση ",
            x,
        )
    )

    # Substituting απελαση variations with απελαση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^απελασ[α-ω]{,8}\s)|(\sαπελασ[α-ω]{,8}$)|(\sαπελασ[α-ω]{,8}\s)",
            " απελαση ",
            x,
        )
    )

    # Substituting πολεμος variations with πολεμος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^πολεμ[α-ω]{,8}\s)|(\sπολεμ[α-ω]{,8}$)|(\sπολεμ[α-ω]{,8}\s)",
            " πολεμος ",
            x,
        )
    )

    # Substituting πολεμος variations with πολεμος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^πολεμ[α-ω]{,8}\s)|(\sπολεμ[α-ω]{,8}$)|(\sπολεμ[α-ω]{,8}\s)",
            " πολεμος ",
            x,
        )
    )

    # Substituting πραγματικος variations with πραγματικος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^πραγματι[α-ω]{,8}\s)|(\sπραγματι[α-ω]{,8}$)|(\sπραγματι[α-ω]{,8}\s)",
            " πραγματικος ",
            x,
        )
    )

    # Substituting πραγματικος variations with πραγματικος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^πραγματι[α-ω]{,8}\s)|(\sπραγματι[α-ω]{,8}$)|(\sπραγματι[α-ω]{,8}\s)",
            " πραγματικος ",
            x,
        )
    )

    # Substituting σεβονται variations with σεβονται
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^σεβεσ[α-ω]{,8}\s)|(\sσεβεσ[α-ω]{,8}$)|(\sσεβεσ[α-ω]{,8}\s)",
            " σεβονται ",
            x,
        )
    )

    # Substituting σεβονται variations with σεβονται
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^σεβεσ[α-ω]{,8}\s)|(\sσεβεσ[α-ω]{,8}$)|(\sσεβεσ[α-ω]{,8}\s)",
            " σεβονται ",
            x,
        )
    )

    # Substituting μουσουλμανοι variations with μουσουλμανοι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^μουσουλμ[α-ω]{,8}\s)(\sμουσουλμ[α-ω]{,8}$)(\sμουσουλμ[α-ω]{,8}\s)",
            " μουσουλμανοι ",
            x,
        )
    )

    # Substituting μουσουλμανοι variations with μουσουλμανοι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^μουσουλμ[α-ω]{,8}\s)|(\sμουσουλμ[α-ω]{,8}$)|(\sμουσουλμ[α-ω]{,8}\s)",
            " μουσουλμανοι ",
            x,
        )
    )

    # Substituting περιθαλψη variations with περιθαλψη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^περιθαλψ[α-ω]{,8}\s)|(\sπεριθαλψ[α-ω]{,8}$)|(\sπεριθαλψ[α-ω]{,8}\s)",
            " περιθαλψη ",
            x,
        )
    )

    # Substituting περιθαλψη variations with περιθαλψη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^περιθαλψ[α-ω]{,8}\s)|(\sπεριθαλψ[α-ω]{,8}$)|(\sπεριθαλψ[α-ω]{,8}\s)",
            " περιθαλψη ",
            x,
        )
    )

    # Substituting ολοι variations with ολοι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ολ[α-ω]{,2}\s)|(\sολ[α-ω]{,2}$)|(\sολ[α-ω]{,2}\s)", " ολοι ", x
        )
    )

    # Substituting ολοι variations with ολοι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ολ[α-ω]{,2}\s)|(\sολ[α-ω]{,2}$)|(\sολ[α-ω]{,2}\s)", " ολοι ", x
        )
    )

    # Substituting ανθρωπινες variations with ανθρωπινες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ανθρωπιν[α-ω]{,8}\s)|(\sανθρωπιν[α-ω]{,8}$)|(\sανθρωπιν[α-ω]{,8}\s)",
            " ανθρωπινες ",
            x,
        )
    )

    # Substituting ανθρωπινες variations with ανθρωπινες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ανθρωπιν[α-ω]{,8}\s)|(\sανθρωπιν[α-ω]{,8}$)|(\sανθρωπιν[α-ω]{,8}\s)",
            " ανθρωπινες ",
            x,
        )
    )

    # Substituting κρατος variations with κρατος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^κρατη\s)|(\sκρατη$)|(\sκρατη\s)", " κρατος ", x)
    )

    # Substituting κρατος variations with κρατος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^κρατη\s)|(\sκρατη$)|(\sκρατη\s)", " κρατος ", x)
    )

    # Substituting σχεδια variations with σχεδια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^σχεδι[α-ω]{,8}\s)|(\sσχεδι[α-ω]{,8}$)|(\sσχεδι[α-ω]{,8}\s)",
            " σχεδια ",
            x,
        )
    )

    # Substituting σχεδια variations with σχεδια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^σχεδι[α-ω]{,8}\s)|(\sσχεδι[α-ω]{,8}$)|(\sσχεδι[α-ω]{,8}\s)",
            " σχεδια ",
            x,
        )
    )

    # Substituting προελευση variations with προελευση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^προελευσ[α-ω]{,8}\s)|(\sπροελευσ[α-ω]{,8}$)|(\sπροελευσ[α-ω]{,8}\s)",
            " προελευση ",
            x,
        )
    )

    # Substituting προελευση variations with προελευση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^προελευσ[α-ω]{,8}\s)|(\sπροελευσ[α-ω]{,8}$)|(\sπροελευσ[α-ω]{,8}\s)",
            " προελευση ",
            x,
        )
    )

    # Substituting απελαση variations with απελαση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^απελα[α-ω]{,8}\s)|(\sαπελα[α-ω]{,8}$)|(\sαπελα[α-ω]{,8}\s)",
            " απελαση ",
            x,
        )
    )

    # Substituting απελαση variations with απελαση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^απελα[α-ω]{,8}\s)|(\sαπελα[α-ω]{,8}$)|(\sαπελα[α-ω]{,8}\s)",
            " απελαση ",
            x,
        )
    )

    # Substituting εθνικος variations with εθνικος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^εθνη\s)|(\sεθνη$)|(\sεθνη\s)", " εθνικος ", x)
    )

    # Substituting εθνικος variations with εθνικος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^εθνη\s)|(\sεθνη$)|(\sεθνη\s)", " εθνικος ", x)
    )

    # Substituting εμπολεμη variations with εμπολεμη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^εμπολεμ[α-ω]{,8}\s)|(\sεμπολεμ[α-ω]{,8}$)|(\sεμπολεμ[α-ω]{,8}\s)",
            " εμπολεμη ",
            x,
        )
    )

    # Substituting εμπολεμη variations with εμπολεμη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^εμπολεμ[α-ω]{,8}\s)|(\sεμπολεμ[α-ω]{,8}$)|(\sεμπολεμ[α-ω]{,8}\s)",
            " εμπολεμη ",
            x,
        )
    )

    # Substituting ελληνας variations with ελληνας
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ελλην[α-ω]{,8}\s)|(\sελλην[α-ω]{,8}$)|(\sελλην[α-ω]{,8}\s)",
            " ελληνας ",
            x,
        )
    )

    # Substituting ελληνας variations with ελληνας
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ελλην[α-ω]{,8}\s)|(\sελλην[α-ω]{,8}$)|(\sελλην[α-ω]{,8}\s)",
            " ελληνας ",
            x,
        )
    )

    # Substituting ανθρωπινες variations with ανθρωπινες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ανθρωπιν[α-ω]{,8}\s)|(\sανθρωπιν[α-ω]{,8}$)|(\sανθρωπιν[α-ω]{,8}\s)",
            " ανθρωπινες ",
            x,
        )
    )

    # Substituting ανθρωπινες variations with ανθρωπινες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ανθρωπιν[α-ω]{,8}\s)|(\sανθρωπιν[α-ω]{,8}$)|(\sανθρωπιν[α-ω]{,8}\s)",
            " ανθρωπινες ",
            x,
        )
    )

    # Removing double spaces
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Removing double spaces
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Substituting χριστιανοι variations with χριστιανοι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^χριστιαν[α-ω]{,8}\s)|(\sχριστιαν[α-ω]{,8}$)|(\sχριστιαν[α-ω]{,8}\s)",
            " χριστιανοι ",
            x,
        )
    )

    # Substituting χριστιανοι variations with χριστιανοι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^χριστιαν[α-ω]{,8}\s)|(\sχριστιαν[α-ω]{,8}$)|(\sχριστιαν[α-ω]{,8}\s)",
            " χριστιανοι ",
            x,
        )
    )

    # Substituting νομος variations with νομος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^νομικ[α-ω]{,8}\s)|(\sνομικ[α-ω]{,8}$)|(\sνομικ[α-ω]{,8}\s)",
            " νομος ",
            x,
        )
    )

    # Substituting νομος variations with νομος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^νομικ[α-ω]{,8}\s)|(\sνομικ[α-ω]{,8}$)|(\sνομικ[α-ω]{,8}\s)",
            " νομος ",
            x,
        )
    )

    # Substituting αφγανισταν variations with αφγανισταν
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^αφγαν[α-ω]{,8}\s)|(\sαφγαν[α-ω]{,8}$)|(\sαφγαν[α-ω]{,8}\s)",
            " αφγανισταν ",
            x,
        )
    )

    # Substituting αφγανισταν variations with αφγανισταν
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^αφγαν[α-ω]{,8}\s)|(\sαφγαν[α-ω]{,8}$)|(\sαφγαν[α-ω]{,8}\s)",
            " αφγανισταν ",
            x,
        )
    )

    # Substituting απελαση variations with απελαση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^απελα[α-ω]{,8}\s)|(\sαπελα[α-ω]{,8}$)|(\sαπελα[α-ω]{,8}\s)",
            " απελαση ",
            x,
        )
    )

    # Substituting απελαση variations with απελαση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^απελα[α-ω]{,8}\s)|(\sαπελα[α-ω]{,8}$)|(\sαπελα[α-ω]{,8}\s)",
            " απελαση ",
            x,
        )
    )

    # Substituting ανοικτη variations with ανοικτη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ανοιχτα[α-ω]{,8}\s)|(\sανοιχτα[α-ω]{,8}$)|(\sανοιχτα[α-ω]{,8}\s)",
            " ανοικτη ",
            x,
        )
    )

    # Substituting ανοικτη variations with ανοικτη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ανοιχτα[α-ω]{,8}\s)|(\sανοιχτα[α-ω]{,8}$)|(\sανοιχτα[α-ω]{,8}\s)",
            " ανοικτη ",
            x,
        )
    )

    # Removing double spaces
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Removing double spaces
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Substituting ποινικο variations with ποινικο
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^ποινες\s)|(\sποινες$)|(\sποινες\s)", " ποινικο ", x)
    )

    # Substituting ποινικο variations with ποινικο
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^ποινες\s)|(\sποινες$)|(\sποινες\s)", " ποινικο ", x)
    )

    # Substituting χαρτια variations with χαρτια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^χαρτι\s)|(\sχαρτι$)|(\sχαρτι\s)", " χαρτια ", x)
    )

    # Substituting χαρτια variations with χαρτια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^χαρτι\s)|(\sχαρτι$)|(\sχαρτι\s)", " χαρτια ", x)
    )

    # Substituting ελληνικη variations with ελληνικη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ελλην[α-ω]{,8}\s)|(\sελλην[α-ω]{,8}$)|(\sελλην[α-ω]{,8}\s)",
            " ελληνικη ",
            x,
        )
    )

    # Substituting ελληνικη variations with ελληνικη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ελλην[α-ω]{,8}\s)|(\sελλην[α-ω]{,8}$)|(\sελλην[α-ω]{,8}\s)",
            " ελληνικη ",
            x,
        )
    )

    # Substituting οφελη variations with οφελη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^οφελ[α-ω]{,8}\s)|(\sοφελ[α-ω]{,8}$)|(\sοφελ[α-ω]{,8}\s)", " οφελη ", x
        )
    )

    # Substituting οφελη variations with οφελη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^οφελ[α-ω]{,8}\s)|(\sοφελ[α-ω]{,8}$)|(\sοφελ[α-ω]{,8}\s)", " οφελη ", x
        )
    )

    # Substituting ανθρωπια variations with ανθρωπια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^_ανθρωπια\s)|(\s_ανθρωπια$)|(\s_ανθρωπια\s)", " ανθρωπια ", x
        )
    )

    # Substituting ανθρωπια variations with ανθρωπια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^_ανθρωπια\s)|(\s_ανθρωπια$)|(\s_ανθρωπια\s)", " ανθρωπια ", x
        )
    )

    # Removing double spaces
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Removing double spaces
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Substituting ηθα variations with ηθα
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^ηθη\s)|(\sηθη$)|(\sηθη\s)", " ηθα ", x)
    )

    # Substituting ηθα variations with ηθα
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^ηθη\s)|(\sηθη$)|(\sηθη\s)", " ηθα ", x)
    )

    # Substituting ηθη variations with ηθη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^ηθα\s)|(\sηθα$)|(\sηθα\s)", " ηθη ", x)
    )

    # Substituting ηθη variations with ηθη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^ηθα\s)|(\sηθα$)|(\sηθα\s)", " ηθη ", x)
    )

    # Substituting δομες variations with δομες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^δομη\s)|(\sδομη$)|(\sδομη\s)", " δομες ", x)
    )

    # Substituting δομες variations with δομες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^δομη\s)|(\sδομη$)|(\sδομη\s)", " δομες ", x)
    )

    # Substituting χαρτια variations with χαρτια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^χαρτη\s)|(\sχαρτη$)|(\sχαρτη\s)", " χαρτια ", x)
    )

    # Substituting χαρτια variations with χαρτια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^χαρτη\s)|(\sχαρτη$)|(\sχαρτη\s)", " χαρτια ", x)
    )

    # Substituting πληρουν variations with πληρουν
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^πληρει\s)|(\sπληρει$)|(\sπληρει\s)", " πληρουν ", x)
    )

    # Substituting πληρουν variations with πληρουν
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^πληρει\s)|(\sπληρει$)|(\sπληρει\s)", " πληρουν ", x)
    )

    # Substituting προυποθεσεις variations with προυποθεσεις
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^προυποθ[α-ω]{,8}\s)|(\sπρουποθ[α-ω]{,8}$)|(\sπρουποθ[α-ω]{,8}\s)",
            " προυποθεσεις ",
            x,
        )
    )

    # Substituting προυποθεσεις variations with προυποθεσεις
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^προυποθ[α-ω]{,8}\s)|(\sπρουποθ[α-ω]{,8}$)|(\sπρουποθ[α-ω]{,8}\s)",
            " προυποθεσεις ",
            x,
        )
    )

    # Substituting μουσουλμανοι variations with μουσουλμανοι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^μουσουλμ[α-ω]{,8}\s)|(\sμουσουλμ[α-ω]{,8}$)|(\sμουσουλμ[α-ω]{,8}\s)",
            " μουσουλμανοι ",
            x,
        )
    )

    # Substituting μουσουλμανοι variations with μουσουλμανοι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^μουσουλμ[α-ω]{,8}\s)|(\sμουσουλμ[α-ω]{,8}$)|(\sμουσουλμ[α-ω]{,8}\s)",
            " μουσουλμανοι ",
            x,
        )
    )

    # Substituting αξιοπρεπεια variations with αξιοπρεπεια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^αξιοπρεπ[α-ω]{,8}\s)|(\sαξιοπρεπ[α-ω]{,8}$)|(\sαξιοπρεπ[α-ω]{,8}\s)",
            " αξιοπρεπεια ",
            x,
        )
    )

    # Substituting αξιοπρεπεια variations with αξιοπρεπεια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^αξιοπρεπ[α-ω]{,8}\s)|(\sαξιοπρεπ[α-ω]{,8}$)|(\sαξιοπρεπ[α-ω]{,8}\s)",
            " αξιοπρεπεια ",
            x,
        )
    )

    # Substituting καταλληλες variations with καταλληλες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^καταλληλ[α-ω]{,8}\s)|(\sκαταλληλ[α-ω]{,8}$)|(\sκαταλληλ[α-ω]{,8}\s)",
            " καταλληλες ",
            x,
        )
    )

    # Substituting καταλληλες variations with καταλληλες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^καταλληλ[α-ω]{,8}\s)|(\sκαταλληλ[α-ω]{,8}$)|(\sκαταλληλ[α-ω]{,8}\s)",
            " καταλληλες ",
            x,
        )
    )

    # Substituting φτωχεια variations with φτωχεια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^φτωχ[α-ω]{,8}\s)|(\sφτωχ[α-ω]{,8}$)|(\sφτωχ[α-ω]{,8}\s)", " φτωχεια ", x
        )
    )

    # Substituting φτωχεια variations with φτωχεια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^φτωχ[α-ω]{,8}\s)|(\sφτωχ[α-ω]{,8}$)|(\sφτωχ[α-ω]{,8}\s)", " φτωχεια ", x
        )
    )

    # Substituting προυπολογισμος variations with προυπολογισμος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^προυπολογισμ[α-ω]{,8}\s)|(\sπρουπολογισμ[α-ω]{,8}$)|(\sπρουπολογισμ[α-ω]{,8}\s)",
            " προυπολογισμος ",
            x,
        )
    )

    # Substituting προυπολογισμος variations with προυπολογισμος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^προυπολογισμ[α-ω]{,8}\s)|(\sπρουπολογισμ[α-ω]{,8}$)|(\sπρουπολογισμ[α-ω]{,8}\s)",
            " προυπολογισμος ",
            x,
        )
    )

    # Substituting σεβασμος variations with σεβασμος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^σεβασμ[α-ω]{,8}\s)|(\sσεβασμ[α-ω]{,8}$)|(\sσεβασμ[α-ω]{,8}\s)",
            " σεβασμος ",
            x,
        )
    )

    # Substituting σεβασμος variations with σεβασμος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^σεβασμ[α-ω]{,8}\s)|(\sσεβασμ[α-ω]{,8}$)|(\sσεβασμ[α-ω]{,8}\s)",
            " σεβασμος ",
            x,
        )
    )

    # Substituting υγειονομικη variations with υγειονομικη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^υγειονομ[α-ω]{,8}\s)|(\sυγειονομ[α-ω]{,8}$)|(\sυγειονομ[α-ω]{,8}\s)",
            " υγειονομικη ",
            x,
        )
    )

    # Substituting υγειονομικη variations with υγειονομικη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^υγειονομ[α-ω]{,8}\s)|(\sυγειονομ[α-ω]{,8}$)|(\sυγειονομ[α-ω]{,8}\s)",
            " υγειονομικη ",
            x,
        )
    )

    # Substituting παιδια variations with παιδια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^παιδ[ι|ακ][α-ω]{,8}\s)|(\sπαιδ[ι|ακ][α-ω]{,8}$)|(\sπαιδ[ι|ακ][α-ω]{,8}\s)",
            " παιδια ",
            x,
        )
    )

    # Substituting παιδια variations with παιδια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^παιδ[ι|ακ][α-ω]{,8}\s)|(\sπαιδ[ι|ακ][α-ω]{,8}$)|(\sπαιδ[ι|ακ][α-ω]{,8}\s)",
            " παιδια ",
            x,
        )
    )

    # Substituting ομαλη variations with ομαλη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ομαλ[α-ω]{,8}\s)|(\sομαλ[α-ω]{,8}$)|(\sομαλ[α-ω]{,8}\s)", " ομαλη ", x
        )
    )

    # Substituting ομαλη variations with ομαλη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ομαλ[α-ω]{,8}\s)|(\sομαλ[α-ω]{,8}$)|(\sομαλ[α-ω]{,8}\s)", " ομαλη ", x
        )
    )

    # Substituting δυτικος variations with δυτικος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^δυτι[α-ω]{,8}\s)|(\sδυτι[α-ω]{,8}$)|(\sδυτι[α-ω]{,8}\s)", " δυτικος ", x
        )
    )

    # Substituting δυτικος variations with δυτικος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^δυτι[α-ω]{,8}\s)|(\sδυτι[α-ω]{,8}$)|(\sδυτι[α-ω]{,8}\s)", " δυτικος ", x
        )
    )

    # Substituting ευρωπη variations with ευρωπη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ευρωπ[α-ω]{,8}\s)|(\sευρωπ[α-ω]{,8}$)|(\sευρωπ[α-ω]{,8}\s)",
            " ευρωπη ",
            x,
        )
    )

    # Substituting ευρωπη variations with ευρωπη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ευρωπ[α-ω]{,8}\s)|(\sευρωπ[α-ω]{,8}$)|(\sευρωπ[α-ω]{,8}\s)",
            " ευρωπη ",
            x,
        )
    )

    # Substituting ποσοστωσεις variations with ποσοστωσεις
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ποσοστ[α-ω]{,8}\s)|(\sποσοστ[α-ω]{,8}$)|(\sποσοστ[α-ω]{,8}\s)",
            " ποσοστωσεις ",
            x,
        )
    )

    # Substituting ποσοστωσεις variations with ποσοστωσεις
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ποσοστ[α-ω]{,8}\s)|(\sποσοστ[α-ω]{,8}$)|(\sποσοστ[α-ω]{,8}\s)",
            " ποσοστωσεις ",
            x,
        )
    )

    # Substituting δαπανες variations with δαπανες
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^δαπαν[α-ω]{,8}\s)|(\sδαπαν[α-ω]{,8}$)|(\sδαπαν[α-ω]{,8}\s)",
            " δαπανες ",
            x,
        )
    )

    # Substituting δαπανες variations with δαπανες
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^δαπαν[α-ω]{,8}\s)|(\sδαπαν[α-ω]{,8}$)|(\sδαπαν[α-ω]{,8}\s)",
            " δαπανες ",
            x,
        )
    )

    # Substituting μισθοι variations with μισθοι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^μισθ[α-ω]{,8}\s)|(\sμισθ[α-ω]{,8}$)|(\sμισθ[α-ω]{,8}\s)", " μισθοι ", x
        )
    )

    # Substituting μισθοι variations with μισθοι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^μισθ[α-ω]{,8}\s)|(\sμισθ[α-ω]{,8}$)|(\sμισθ[α-ω]{,8}\s)", " μισθοι ", x
        )
    )

    # Substituting αλλοιωση variations with αλλοιωση
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^αλλοιω[α-ω]{,8}\s)|(\sαλλοιω[α-ω]{,8}$)|(\sαλλοιω[α-ω]{,8}\s)",
            " αλλοιωση ",
            x,
        )
    )

    # Substituting αλλοιωση variations with αλλοιωση
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^αλλοιω[α-ω]{,8}\s)|(\sαλλοιω[α-ω]{,8}$)|(\sαλλοιω[α-ω]{,8}\s)",
            " αλλοιωση ",
            x,
        )
    )

    # Substituting ιστος variations with ιστος
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"(^ιστη\s)|(\sιστη$)|(\sιστη\s)", " ιστος ", x)
    )

    # Substituting ιστος variations with ιστος
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"(^ιστη\s)|(\sιστη$)|(\sιστη\s)", " ιστος ", x)
    )

    # Substituting ιατρικη variations with ιατρικη
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ιατρικ[α-ω]{,8}\s)|(\sιατρικ[α-ω]{,8}$)|(\sιατρικ[α-ω]{,8}\s)",
            " ιατρικη ",
            x,
        )
    )

    # Substituting ιατρικη variations with ιατρικη
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ιατρικ[α-ω]{,8}\s)|(\sιατρικ[α-ω]{,8}$)|(\sιατρικ[α-ω]{,8}\s)",
            " ιατρικη ",
            x,
        )
    )

    # Substituting καρυδι variations with καρυδι
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^καρυδ[α-ω]{,8}\s)|(\sκαρυδ[α-ω]{,8}$)|(\sκαρυδ[α-ω]{,8}\s)",
            " καρυδι ",
            x,
        )
    )

    # Substituting καρυδι variations with καρυδι
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^καρυδ[α-ω]{,8}\s)|(\sκαρυδ[α-ω]{,8}$)|(\sκαρυδ[α-ω]{,8}\s)",
            " καρυδι ",
            x,
        )
    )

    # Substituting χαρτια variations with χαρτια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^χαρτ[α-ω]{,8}\s)|(\sχαρτ[α-ω]{,8}$)|(\sχαρτ[α-ω]{,8}\s)", " χαρτια ", x
        )
    )

    # Substituting χαρτια variations with χαρτια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^χαρτ[α-ω]{,8}\s)|(\sχαρτ[α-ω]{,8}$)|(\sχαρτ[α-ω]{,8}\s)", " χαρτια ", x
        )
    )

    # Substituting απολυτως variations with απολυτως
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^α _πολυ τως\s)|(\sα _πολυ τως$)|(\sα _πολυ τως\s)", " απολυτως ", x
        )
    )

    # Substituting απολυτως variations with απολυτως
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^α _πολυ τως\s)|(\sα _πολυ τως$)|(\sα _πολυ τως\s)", " απολυτως ", x
        )
    )

    # Substituting ανεργια variations with ανεργια
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(
            r"(^ανεργ[α-ω]{,8}\s)|(\sανεργ[α-ω]{,8}$)|(\sανεργ[α-ω]{,8}\s)",
            " ανεργια ",
            x,
        )
    )

    # Substituting ανεργια variations with ανεργια
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(
            r"(^ανεργ[α-ω]{,8}\s)|(\sανεργ[α-ω]{,8}$)|(\sανεργ[α-ω]{,8}\s)",
            " ανεργια ",
            x,
        )
    )

    # Removing double spaces
    text_analysis.cleaned = text_analysis.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    # Removing double spaces
    councilors_spelled.cleaned = councilors_spelled.cleaned.apply(
        lambda x: re.sub(r"\s+", " ", x)
    )

    return text_analysis, councilors_spelled
