<?php


namespace App\Model\User\UseCase\Activate;

namespace App\Model\User\UseCase\Activate;

use Symfony\Component\Validator\Constraints as Assert;

class Command
{
    /**
     * @Assert\NotBlank()
     */
    public $id;

    public function __construct(string $id)
    {
        $this->id = $id;
    }
}