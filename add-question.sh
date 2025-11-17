#!/bin/bash

# Colors for better UX
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CONFIG_FILE="questions.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: 'jq' is required but not installed.${NC}"
    echo "Please install jq:"
    echo "  macOS: brew install jq"
    echo "  Linux: sudo apt-get install jq"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: $CONFIG_FILE not found${NC}"
    exit 1
fi

echo -e "${BLUE}=== Add New Question ===${NC}\n"

# Get question text
echo -e "${YELLOW}Enter the question text:${NC}"
read -r question_text

if [ -z "$question_text" ]; then
    echo -e "${RED}Error: Question text cannot be empty${NC}"
    exit 1
fi

# Get question type
echo -e "\n${YELLOW}Is this a yes/no question or a 1-5 scale question?${NC}"
echo "1) Yes/No"
echo "2) 1-5 Scale"
read -p "Enter choice (1 or 2): " question_type_choice

case $question_type_choice in
    1)
        question_type="yesno"
        ;;
    2)
        question_type="scale"
        ;;
    *)
        echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}"
        exit 1
        ;;
esac

# Get labels if scale question
if [ "$question_type" = "scale" ]; then
    echo -e "\n${YELLOW}Enter the label for the minimum value (1):${NC}"
    read -r min_label

    if [ -z "$min_label" ]; then
        echo -e "${RED}Error: Minimum label cannot be empty${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Enter the label for the maximum value (5):${NC}"
    read -r max_label

    if [ -z "$max_label" ]; then
        echo -e "${RED}Error: Maximum label cannot be empty${NC}"
        exit 1
    fi
fi

# Read current questions and determine next field name
questions_count=$(jq '.questions | length' "$CONFIG_FILE")
yesno_count=$(jq '[.questions[] | select(.type == "yesno")] | length' "$CONFIG_FILE")
scale_count=$(jq '[.questions[] | select(.type == "scale")] | length' "$CONFIG_FILE")

if [ "$question_type" = "yesno" ]; then
    field_number=$((yesno_count + 1))
    field_name="question${field_number}"
else
    field_number=$((scale_count + 1))
    field_name="scale${field_number}"
fi

# Build the new question object
if [ "$question_type" = "yesno" ]; then
    new_question=$(jq -n \
        --arg type "$question_type" \
        --arg text "$question_text" \
        --arg field "$field_name" \
        '{type: $type, text: $text, field: $field}')
else
    new_question=$(jq -n \
        --arg type "$question_type" \
        --arg text "$question_text" \
        --arg field "$field_name" \
        --arg minLabel "$min_label" \
        --arg maxLabel "$max_label" \
        '{type: $type, text: $text, field: $field, minLabel: $minLabel, maxLabel: $maxLabel}')
fi

# Add the new question to the config file
jq --argjson new_question "$new_question" '.questions += [$new_question]' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"

if [ $? -eq 0 ]; then
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo -e "\n${GREEN}✓ Question added successfully!${NC}"
    echo -e "\n${BLUE}Summary:${NC}"
    echo -e "  Type: ${question_type}"
    echo -e "  Field: ${field_name}"
    echo -e "  Text: ${question_text}"
    if [ "$question_type" = "scale" ]; then
        echo -e "  Min Label: ${min_label}"
        echo -e "  Max Label: ${max_label}"
    fi
    echo -e "\n${BLUE}Total questions: $((questions_count + 1))${NC}"
else
    echo -e "${RED}Error: Failed to update $CONFIG_FILE${NC}"
    rm -f "${CONFIG_FILE}.tmp"
    exit 1
fi
