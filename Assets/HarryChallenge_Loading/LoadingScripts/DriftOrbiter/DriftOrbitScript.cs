using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DriftOrbitScript : MonoBehaviour
{
    [Header("Target Variables")]
    public Transform target;
    private Vector3 shiftingTarget;
    public float speed = .05f;
    public float targetSpeed = .02f;

    [Header("Animation Variables")]
    public Animator LoaderAnimator;
    public float TimerMax = 10f;
    public float TimerMin = 5f;
    [SerializeField]
    float Timer;



    // Start is called before the first frame update
    void Start()
    {
        shiftingTarget = target.position;
        Timer = Random.Range(TimerMin, TimerMax);
    }

    // Update is called once per frame
    void Update()
    {
        shiftingTarget = Vector3.Lerp(shiftingTarget, target.position, targetSpeed);
        transform.position = Vector3.Lerp(transform.position, shiftingTarget, speed);
        Timer -= Time.deltaTime;
        if(Timer <= 0)
        {
            LoaderAnimator.SetTrigger("Fly2");
            Timer = Random.Range(TimerMin, TimerMax);
        }

    }
}
